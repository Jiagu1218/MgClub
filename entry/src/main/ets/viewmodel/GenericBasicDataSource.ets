// GenericBasicDataSource 实现 IDataSource，用于配合 LazyForEach 进行懒渲染
export class GenericBasicDataSource<T> implements IDataSource {
  private listeners: DataChangeListener[] = [];
  private originDataArray: T[] = [];

  public totalCount(): number {
    return this.originDataArray.length;
  }

  public getData(index: number): T {
    return this.originDataArray[index];
  }

  // 供业务侧使用：整体重载数据
  public setData(data: T[]): void {
    this.originDataArray = data;
    this.notifyDataReload();
  }

  // 供业务侧使用：在末尾追加数据
  public appendData(data: T[]): void {
    const start: number = this.originDataArray.length;
    let i: number;
    for (i = 0; i < data.length; i++) {
      this.originDataArray.push(data[i]);
      this.notifyDataAdd(start + i);
    }
  }

  // 该方法为框架侧调用，为 LazyForEach 组件向其数据源处添加 listener 监听
  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  // 该方法为框架侧调用，为对应的 LazyForEach 组件在数据源处去除 listener 监听
  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos: number = this.listeners.indexOf(listener);
    if (pos >= 0) {
      this.listeners.splice(pos, 1);
    }
  }

  // 通知 LazyForEach 组件需要重载所有子组件
  notifyDataReload(): void {
    this.listeners.forEach((listener: DataChangeListener) => {
      listener.onDataReloaded();
    });
  }

  // 通知 LazyForEach 组件需要在 index 对应索引处添加子组件
  notifyDataAdd(index: number): void {
    this.listeners.forEach((listener: DataChangeListener) => {
      if (listener.onDataAdd !== undefined) {
        listener.onDataAdd(index);
      }
    });
  }

  // 通知 LazyForEach 组件在 index 对应索引处数据有变化，需要重建该子组件
  notifyDataChange(index: number): void {
    this.listeners.forEach((listener: DataChangeListener) => {
      if (listener.onDataChange !== undefined) {
        listener.onDataChange(index);
      }
    });
  }

  // 通知 LazyForEach 组件需要在 index 对应索引处删除该子组件
  notifyDataDelete(index: number): void {
    this.listeners.forEach((listener: DataChangeListener) => {
      if (listener.onDataDelete !== undefined) {
        listener.onDataDelete(index);
      }
    });
  }

  // 通知 LazyForEach 组件将 from 索引和 to 索引处的子组件进行交换
  notifyDataMove(from: number, to: number): void {
    this.listeners.forEach((listener: DataChangeListener) => {
      if (listener.onDataMove !== undefined) {
        listener.onDataMove(from, to);
      }
    });
  }

  notifyDatasetChange(operations: DataOperation[]): void {
    this.listeners.forEach((listener: DataChangeListener) => {
      if (listener.onDatasetChange !== undefined) {
        listener.onDatasetChange(operations);
      }
    });
  }
}

