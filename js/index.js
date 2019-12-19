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
    const currentUrl = localStorage.getItem('nextUrl');
    const offsets = { x : window.pageXOffset, y : window.pageYOffset };
    localStorage.setItem(currentUrl, JSON.stringify(offsets));
    localStorage.setItem('currentUrl', currentUrl);
    localStorage.setItem('nextUrl', location.href);
    console.log(currentUrl, JSON.stringify(offsets));
    app.ports.onPopState.send(null);
  } catch (err) {
    console.log(err);
  }
};

app.ports.getLocation.subscribe(() => {
  app.ports.gotLocation.send(location.href);
});

// Change the URL upon request, inform app of the change.
app.ports.pushUrl.subscribe((nextUrl) => {
  try {
    const offsets = { x : window.pageXOffset, y : window.pageYOffset };
    const currentUrl = location.href;
    localStorage.setItem(currentUrl, JSON.stringify(offsets));
    localStorage.setItem('currentUrl', currentUrl);
    localStorage.setItem('nextUrl', nextUrl);
    history.pushState({}, '', nextUrl);
    console.log(currentUrl, JSON.stringify(offsets));
    app.ports.onUrlChange.send(null);
  } catch (err) {
    console.log(err);
  }
});

app.ports.setOffsets.subscribe( () => {
  requestAnimationFrame( () => {
    const nextUrl = localStorage.getItem('nextUrl');
    const offsets = JSON.parse(localStorage.getItem(nextUrl));
    if(offsets) {
      window.scroll(offsets.x, offsets.y);
    }
  })
});
