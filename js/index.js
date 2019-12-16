require('../css/style.css');
const { Elm } = require('../src/Main.elm');

var app = Elm.Main.init({
  node: document.getElementById('elm'),
  flags: location.href
});

// Inform app of browser navigation (the BACK and FORWARD buttons)
window.onpopstate = () => {
  console.log(window.pageYOffset);
  app.ports.onPopState.send(location.href);
};

app.ports.getLocation.subscribe(() => {
  app.ports.gotLocation.send(location.href);
});

app.ports.getLocationP.subscribe(() => {
  app.ports.gotLocationP.send(location.href);
});
// Change the URL upon request, inform app of the change.
app.ports.pushUrl.subscribe(function(url) {
  history.pushState({}, '', url);
  app.ports.onUrlChange.send(location.href);
});
