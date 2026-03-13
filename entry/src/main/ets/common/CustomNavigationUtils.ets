export interface AnimateCallback {
  start?: (isPush: boolean, isExit: boolean) => void;
  finish?: (isPush: boolean, isExit: boolean) => void;
}

const customTransitionMap: Map<string, AnimateCallback> = new Map<string, AnimateCallback>();

export class CustomTransition {
  private static delegate: CustomTransition = new CustomTransition();

  static getInstance(): CustomTransition {
    return CustomTransition.delegate;
  }

  registerNavParam(name: string,
    startCallback: (isPush: boolean, isExit: boolean) => void,
    endCallback: (isPush: boolean, isExit: boolean) => void): void {
    if (customTransitionMap.has(name)) {
      let param: AnimateCallback | undefined = customTransitionMap.get(name);
      if (param !== undefined) {
        param.start = startCallback;
        param.finish = endCallback;
        return;
      }
    }
    let params: AnimateCallback = { start: startCallback, finish: endCallback };
    customTransitionMap.set(name, params);
  }

  unRegisterNavParam(name: string): void {
    customTransitionMap.delete(name);
  }

  getAnimateParam(name: string): AnimateCallback {
    let stored: AnimateCallback | undefined = customTransitionMap.get(name);
    let result: AnimateCallback = {
      start: stored !== undefined ? stored.start : undefined,
      finish: stored !== undefined ? stored.finish : undefined
    };
    return result;
  }
}
