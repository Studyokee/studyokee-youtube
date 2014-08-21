'use strict';

var mongoose = require('mongoose');
var q = require('q');
var songHelpers = require('./helpers/song');
var request = require('request');

var Song;

var songSchema = mongoose.Schema({
    rdioKey: {
        type: String
    },
    youtubeKey: {
        type: String
    },
    youtubeOffset: Number,
    metadata: {
        artist: String,
        trackName: String,
        language: String
    },
    subtitles: [{
        text: String,
        ts: Number
    }],
    translations: [{
        language: String,
        data: [String]
    }]
});

function findOne (query) {
    var findOneRequest = q.defer();
    Song.findOne(query, findOneRequest.makeNodeResolver());
    return findOneRequest.promise;
}

function save (saveObj) {
    var song = new Song(saveObj);
    var saveRequest = q.defer();
    song.save(saveRequest.makeNodeResolver());
    return saveRequest.promise.spread(function(res) {
        return q.resolve(res);
    });
}

songSchema.methods.getTranslation = function(toLanguage) {
    var song = this;
    return q.resolve().then(function () {
        var translation = songHelpers.getTranslationByLanguageFromArray(song.translations, toLanguage);

        if (translation && translation.data) {
            console.log('found existing translation');
            return translation.data;
        }

        var result = null;
        return Song.getDefaultTranslation(song, toLanguage).then(function (translation) {
            var translations = song.translations.slice();
            translations.push({
                language: toLanguage,
                data: translation
            });

            var updates = {
                translations: translations
            };
            var updateRequest = q.defer();
            song.update(updates, updateRequest.makeNodeResolver());

            result = translation;
            return updateRequest.promise;
        }).then(function () {
            return result;
        });
    }).then(function (translation) {
        return translation;
    });
};

songSchema.methods.getSubtitles = function () {
    var song = this;
    return q.resolve().then(function () {
        if (song.subtitles && song.subtitles.length > 0) {
            console.log('found existing subtitles');
            return song.subtitles;
        }

        var result = null;
        return songHelpers.getSubtitles(song.metadata.artist, song.metadata.trackName).then(function (subtitles) {
            var updates = {
                subtitles: subtitles
            };
            var updateRequest = q.defer();
            song.update(updates, updateRequest.makeNodeResolver());

            result = subtitles;
            return updateRequest.promise;
        }).then(function () {
            return result;
        });
    }).then(function (subtitles) {
        return subtitles;
    });
};

songSchema.methods.getLanguage = function () {
    var song = this;
    return q.resolve().then(function () {
        if (song.metadata && song.metadata.language) {
            console.log('found existing language');
            return song.metadata.language;
        }

        var result = null;
        return song.getSubtitles().then(function (subtitles) {
            return songHelpers.getLanguage(subtitles);
        }).then(function (language) {
            if (!language) {
                return q.defer().reject('no language identified');
            }

            var languageUpdate = {
                metadata: {
                    language: language
                }
            };
            var updateRequest = q.defer();
            song.update(languageUpdate, updateRequest.makeNodeResolver());

            result = language;
            return updateRequest.promise;
        }).then(function () {
            return result;
        });
    }).then(function (language) {
        return language;
    });
};

songSchema.static('getDefaultTranslation', function (song, toLanguage) {
    return q.resolve().then(function () {
        return q.all([
            song.getSubtitles(),
            song.getLanguage()
        ]);
    }).spread(function (subtitles, fromLanguage) {
        if (fromLanguage === toLanguage) {
            return q.defer().reject('same language as native language!');
        }
        
        return songHelpers.getDefaultTranslation(subtitles, fromLanguage, toLanguage);
    });
});

songSchema.static('getSubtitles', function (artist, trackName) {
    return q.resolve().then(function () {
        return songHelpers.getSubtitles(artist, trackName);
    });
});

songSchema.static('getByQuery', function (query) {
    if (!query) {
        return q.reject('No query provided');
    }

    return findOne(query).then(function (song) {
        if (song) {
            return song;
        }
        
        console.log('failed to find rdio key, creating new one...');
        return save(query).fail(function() {
            // Save failed, try to get again in case concurrent request caused failure
            return findOne(query);
        });
    });
});

// Given a list of ids, return the song objects plus video snippets
songSchema.static('getDisplayInfo', function (ids) {
    var songs = [];
    return q.resolve().then(function () {
        console.log('ids: ' + JSON.stringify(ids, null, 4));
        if (!ids || ids.length === 0) {
            return [];
        }

        var getRequest = q.defer();
        Song.find({
            _id: {$in: ids}
        }, getRequest.makeNodeResolver());
        return getRequest.promise;
    }).then(function (result) {
        songs = result;

        var videoIds = [];
        for (var i = 0; i < songs.length; i++) {
            if (songs[i].youtubeKey) {
                videoIds.push(songs[i].youtubeKey);
            }
        }

        if (videoIds.length === 0) {
            return songs;
        }

        var url = 'https://www.googleapis.com/youtube/v3/videos?part=snippet';
        url += '&key=' + process.env.GOOGLE_API_KEY;
        url += '&id=' + videoIds.join();
        console.log('url: ' + JSON.stringify(url, null, 4));

        var getVideoSnippetsRequest = q.defer();
        request.get({
            url: url,
            json: true
        }, getVideoSnippetsRequest.makeNodeResolver());
        return getVideoSnippetsRequest.promise;
    }).spread(function (videosResult) {
        var videos = videosResult.body.items;
        var toReturn = [];
        for (var i = 0; i < songs.length; i++) {
            var item = {};
            var song = songs[i];
            for (var j = 0; j < videos.length; j++) {
                var videoSnippet = videos[j];
                if (song.youtubeKey === videoSnippet.id) {
                    item.videoSnippet = videoSnippet;
                }
            }
            item.song = song;
            toReturn.push(item);
        }

        return toReturn;
    }).fail(function (err) {
        console.log('Error with getVideoSnippets: ' + err);
    });
});

Song = mongoose.model('Song', songSchema);
module.exports = Song;