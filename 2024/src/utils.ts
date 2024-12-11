export class Cache<T, U> {
  private cache: Record<string, U> = {};

  get(...args: T[]) {
    return this.cache[this.key(...args)];
  }

  has(...args: T[]) {
    return this.key(...args) in this.cache;
  }

  set(value: U, ...args: T[]) {
    this.cache[this.key(...args)] = value;
  }

  private key(...args: T[]) {
    return JSON.stringify(args);
  }
}
