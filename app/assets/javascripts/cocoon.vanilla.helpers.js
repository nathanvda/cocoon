(function(){
  // Start delegate $(document).on('event', 'element', function) on vanillaJs
  var CustomEvent = window.CustomEvent;

  if (typeof CustomEvent === 'function') {
    CustomEvent = function(event, params) {
      var evt;
      evt = document.createEvent('CustomEvent');
      evt.initCustomEvent(event, params.bubbles, params.cancelable, params.detail);
      return evt;
    };
    CustomEvent.prototype = window.Event.prototype;
  }

  var fire = function(obj, name, data) {
    var event;
    event = new CustomEvent(name, {
      bubbles: true,
      cancelable: true,
      detail: data
    });

    obj.dispatchEvent(event);
    return !event.defaultPrevented;
  };

  var m = Element.prototype.matches || Element.prototype.matchesSelector || Element.prototype.mozMatchesSelector || Element.prototype.msMatchesSelector || Element.prototype.oMatchesSelector || Element.prototype.webkitMatchesSelector;

  var matches = function(element, selector) {
    if (selector.exclude != null) {
      return m.call(element, selector.selector) && !m.call(element, selector.exclude);
    } else {
      return m.call(element, selector);
    }
  };

  var delegate = function(element, selector, eventType, handler) {
    return element.addEventListener(eventType, function(e) {
      var target;
      target = e.target;
      while (!(!(target instanceof Element) || matches(target, selector))) {
        target = target.parentNode;
      }
      if (target instanceof Element && handler.call(target, e) === false) {
        e.preventDefault();
        return e.stopPropagation();
      }
    });
  };

  var getPreviousSibling = function (elem, selector) {

    // Get the next sibling element
    var sibling = elem.previousElementSibling;

    // If there's no selector, return the first sibling
    if (!selector) return sibling;

    // If the sibling matches our selector, use it
    // If not, jump to the next sibling and continue the loop
    while (sibling) {
      if (sibling.matches(selector)) return sibling;
      sibling = sibling.previousElementSibling;
    }

  };

  window.CocoonHelper = { 
    CustomEvent, 
    fire,
    matches,
    delegate,
    getPreviousSibling
  }
  // end delegate
})();