module.exports = {
  transform: {"^.+\\.ts?$": "ts-jest"},
  testEnvironment: "node",
  testRegex: ".*\\.(test|spec)?\\.ts$",
  testTimeout: 5000,
  moduleFileExtensions: ["ts", "js", "json", "node"]
};
