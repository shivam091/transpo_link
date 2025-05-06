export function isPreview() {
  return window.Stimulus?.element?.hasAttribute("data-turbo-preview");
}

export function resolveControllerByIdentifier(identifier) {
  return window.Stimulus?.controllers?.find(controller => {
    return controller.context.identifier === identifier;
  });
}

export function resolveControllerByElementAndIdentifier(element, identifier) {
  return window.Stimulus?.getControllerForElementAndIdentifier(element, identifier);
}

export function getParentController(element, identifier) {
  do {
    const controller = window.Stimulus?.getControllerForElementAndIdentifier(element, identifier);
    if (controller) return controller;
  } while (element = element.parentElement);
}
