const functions = require('firebase-functions');

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//

let admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);
exports.sendPush = functions.database.ref('/game/{gid}/MisterX').onWrite(event => {

    let gameId = event.params.gid;
    sendLocationUpdatedMessage(gameId);
    setTimeout(function(){ sendUpdateLocationMessage(gameId); }, 299000);
    return 0;
});

function sendUpdateLocationMessage(gameId) {
  return loadUsers(gameId).then(data => {
        let users = [];
        for (var property in data) {
            users.push(data[property]);
        }
        let tokens = [];
        for (let user of users) {
            if (user.MisterX && user.pushToken != "") {
                tokens.push(user.pushToken);
            }
        }
        let payload = {
            notification: {
                title: 'Update Location',
                body: 'Update Location',
                sound: 'default',
                badge: '0'
            }
        };

        const options = {
            content_available: true
        }

        return admin.messaging().sendToDevice(tokens, payload, options);
    });
}

function sendLocationUpdatedMessage(gameId) {
  return loadUsers(gameId).then(data => {
        let users = [];
        for (var property in data) {
            users.push(data[property]);
        }
        let tokens = [];
        for (let user of users) {
            if (!user.MisterX && user.pushToken != "") {
                tokens.push(user.pushToken);
            }
        }
        let payload = {
            notification: {
                title: 'Location of Mister X was updated',
                body: 'Location of Mister X was updated',
                sound: 'default',
                badge: '0'
            }
        };
        return admin.messaging().sendToDevice(tokens, payload);
    });
}

exports.sendChatPush = functions.database.ref('/game/{gid}/messages/{mid}').onCreate(event => {

    let gameId = event.params.gid;
    let messageId = event.params.mid;

    return loadMessageData(gameId, messageId).then(data => {

        let senderId = data.sender_id;
        let text = data.text;

        return loadUsers(gameId).then(data => {
              let userIds = Object.keys(data);
              let users = [];
              for (var property in data) {
                  users.push(data[property]);
              }
              let tokens = [];
              for (i = 0; i < users.length; i++) {
                  if (userIds[i] != senderId) {
                      tokens.push(users[i].pushToken);
                  }
              }
              let payload = {
                  notification: {
                      title: 'You have a new message!',
                      body: text,
                      sound: 'default',
                      badge: '0'
                  }
              };
              return admin.messaging().sendToDevice(tokens, payload);
          });
      });
});

exports.sendNewGamePush = functions.database.ref('/game/{gid}/MisterX').onDelete(event => {

    let gameId = event.params.gid;
    sendNewGame(gameId);
    return 0;
});

function sendNewGame(gameId) {
  return loadUsers(gameId).then(data => {
        let users = [];
        for (var property in data) {
            users.push(data[property]);
        }
        let tokens = [];
        for (let user of users) {
            tokens.push(user.pushToken);
        }
        let payload = {
            notification: {
                title: 'New game created',
                body: 'New game created',
                sound: 'default',
                badge: '0'
            }
        };

        return admin.messaging().sendToDevice(tokens, payload);
    });
}

exports.sendDeletePush = functions.database.ref('/game/{gid}/gameClosed').onWrite(event => {

    let gameId = event.params.gid;
    let gameClosed = event.data.val();
    console.log(event.data.val());
    if (gameClosed) {
        sendGameDelete(gameId);
    }
    return 0;
});

function sendGameDelete(gameId) {
  return loadUsers(gameId).then(data => {
        let users = [];
        for (var property in data) {
            users.push(data[property]);
        }
        let tokens = [];
        for (let user of users) {
            if (!user.MisterX) {
                tokens.push(user.pushToken);
            }
        }
        let payload = {
            notification: {
                title: 'Game was deleted',
                body: 'current game was deleted by misterX',
                sound: 'default',
                badge: '0'
            }
        };
        deleteGame(gameId);
        return admin.messaging().sendToDevice(tokens, payload);
    });
}

function deleteGame(gameId) {
    admin.database().ref('/game/' + gameId).remove();
}

function loadUsers(gameId) {
  let dbRef = admin.database().ref('/game/' + gameId + '/player');
    let defer = new Promise((resolve, reject) => {
        dbRef.once('value', (snap) => {
            let data = snap.val();
            resolve(data);
        }, (err) => {
            reject(err);
        });
    });
    return defer;
}


function loadMessageData(gameId, messageId) {

  let dbRef = admin.database().ref('/game/' + gameId + '/messages/' + messageId);
    let defer = new Promise((resolve, reject) => {
        dbRef.once('value', (snap) => {
            let data = snap.val();
            resolve(data);
        }, (err) => {
            reject(err);
        });
    });
    return defer;
}
