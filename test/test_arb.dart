var testArb = {
  "@@locale": "en",
  "example": "Example",
  "hello": "Hello {userName}",
  "@hello": {
    "description": "A message with a single parameter",
    "placeholders": {
      "userName": {"type": "String", "example": "Bob"}
    }
  },
  "nThings": "{count,plural, =0{no {thing}s} other{{count} {thing}s}}",
  "@nThings": {
    "description": "A plural message with an additional parameter",
    "placeholders": {
      "count": {"type": "int"},
      "thing": {"example": "wombat"}
    }
  },
  "counter": "Counter: {value}",
  "@counter": {
    "description": "A message with a formatted int parameter",
    "placeholders": {
      "value": {"type": "int", "format": "compactLong"}
    }
  }
};

var testPreviewArb = {
  "@@locale": "en",
  "example": "preview_Example",
  "hello": "preview_Hello {userName}",
  "@hello": {
    "description": "A message with a single parameter",
    "placeholders": {
      "userName": {"type": "String", "example": "Bob"}
    }
  },
  "nThings": "{count,plural, =0{no preview_{thing}s} other{{count} preview_{thing}s}}",
  "@nThings": {
    "description": "A plural message with an additional parameter",
    "placeholders": {
      "count": {"type": "int"},
      "thing": {"example": "wombat"}
    }
  },
  "counter": "preview_Counter: {value}",
  "@counter": {
    "description": "A message with a formatted int parameter",
    "placeholders": {
      "value": {"type": "int", "format": "compactLong"}
    }
  }
};
