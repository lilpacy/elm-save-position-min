require('../css/style.css');
const { Elm } = require('../src/Main.elm');

localStorage.clear();

var app = Elm.Main.init({
  node: document.getElementById('elm'),
  flags: location.href
});

// Inform app of browser navigation (the BACK and FORWARD buttons)
window.onpopstate = () => {
  try {
    app.ports.onPopState.send(null);
    const currentUrl = localStorage.getItem('currentUrl');
    localStorage.setItem('previousUrl', currentUrl);
    localStorage.setItem('currentUrl', location.href);
  } catch (err) {
    console.log(err);
  }
};

app.ports.getLocation.subscribe(() => {
  app.ports.gotLocation.send(location.href);
});

app.ports.getLocationP.subscribe(() => {
  app.ports.gotLocationP.send(location.href);
});
// Change the URL upon request, inform app of the change.
app.ports.pushUrl.subscribe((url) => {
  try {
    history.pushState({}, '', url);
    localStorage.setItem('previousUrl', location.href);
    localStorage.setItem('currentUrl', url);
    app.ports.onUrlChange.send(null);
  } catch (err) {
    console.log(err);
  }
});
