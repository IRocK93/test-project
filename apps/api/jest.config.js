module.exports = {
  moduleFileExtensions: ['js', 'json', 'ts'],
  rootDir: 'src',
  transform: {
    '^.+\\.(t|j)s$': 'ts-jest',
  },
  collectCoverageFrom: ['**/*.(t|j)s'],
  coverageDirectory: '../coverage',
  testEnvironment: 'node',
  preset: 'ts-jest',
  testMatch: ['**/__tests__/**/*.[jt]s?(c)', '**/?(*.)+(spec|test).[tj]s?(c)'],
  moduleNameMapper: {
    '^src/(.*)$': '<rootDir>/$1',
  },
  coverageThreshold: {
    global: {
      branches: 30,
      functions: 30,
      lines: 40,
      statements: 40,
    },
  },
};
