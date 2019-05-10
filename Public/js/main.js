
class User {

    static get token() {
        return localStorage.getItem("token");
    }

    static async loggedIn() {
        if (!this.token) return false;
        axios.defaults.headers.common['Authorization'] = 'Bearer ' + this.token;

        try {
            const response = await axios.get("/user/test");
            console.log(response);
            return response.data;
        } catch (error) {
            console.log(error);
            return false;
        }
    }

    static async login (username, password) {
        try {
            const response = await axios.get("/user/login", {
                auth: {
                    username,
                    password 
                }
            });
            localStorage.setItem("token", response.data.token);
            axios.defaults.headers.common['Authorization'] = 'Bearer ' + response.data.token;
            this.username = username;
        } catch (error) {
            // TODO: Do real errors
            alert("Login failed");
            console.log(error);
        }
    }

}

class Chat {

    constructor() {
        this.socket = new WebSocket("ws://localhost:8080/connect/?token=" + User.token);
        this.socket.onopen = this.onOpen.bind(this);
        this.socket.onmessage = this.onMessage.bind(this);
        this.socket.onclose = this.onClose.bind(this);

        document.getElementById('sendButton').addEventListener('click', this.onSendButton.bind(this));
    }

    addMessage(sender, text) {
        const messageElement = document.createElement("b");
        const senderElement = document.createElement("span");
        const messageContentElement = document.createElement("i");
        const breakElement = document.createElement("br");

        senderElement.innerText = sender;
        messageContentElement.innerText = text;

        messageElement.appendChild(senderElement);
        messageElement.appendChild(messageContentElement);
        messageElement.appendChild(breakElement);
        document.getElementById("messageBox").appendChild(messageElement);
    }

    renderMessages(messageArray) {
        document.getElementById("messageBox").innerHTML = "";
        messageArray.forEach(messageObject => {
            this.addMessage("Sender", messageObject.message);
        });
    }

    onSendButton(e) {
        const text = document.getElementById("sendInput").value;
        if (text == "") return;
        document.getElementById("sendInput").value = "";

        this.socket.send(text);
        this.addMessage(User.username, text);
    }

    onOpen(e) {
        console.log(e);
    }

    onMessage(e) {
        console.log("Received message " + e.data);
        if (e.data.startsWith("[") || e.data.startsWith("{")) {
            const dataObject = JSON.parse(e.data);
            this.renderMessages(dataObject);
        } else {
            console.log("not json");
        }
    }

    onClose(e) {
        console.log(e);
    }

}

async function onLoginButtonClick()
{
    const username = document.getElementById("username").value;
    const password = document.getElementById("password").value;
    await User.login(username, password);
    if (await User.loggedIn()) {
        document.getElementById("username").parentElement.removeChild(document.getElementById("username"));
        document.getElementById("password").parentElement.removeChild(document.getElementById("password"));
        document.getElementById("loginButton").parentElement.removeChild(document.getElementById("loginButton"));
        window.chatInstance = new Chat();
    } else {

    }
}

window.addEventListener('load', e => {
    User.loggedIn().then(user => {
        if (user) {
            User.username = user.username;
            console.log("logged in")
            window.chatInstance = new Chat();
            document.getElementById("username").parentElement.removeChild(document.getElementById("username"));
            document.getElementById("password").parentElement.removeChild(document.getElementById("password"));
            document.getElementById("loginButton").parentElement.removeChild(document.getElementById("loginButton"));
        } else {
            console.log("not logged in");
        }
    });

    document.getElementById("loginButton").addEventListener('click', onLoginButtonClick);
});
