---
title: PaddleSOT-SideEffect
date: 2023-08-04 11:12:15
tags:
  - python
categories:
  - 原理
  - 机制
keywords: python, Bytecodes, cpython
description: 以PaddleSOT中的global为例, 介绍SideEffect的相关知识
cover: https://www.python.org/static/img/python-logo-large.c36dccadd999.png
---

## 什么是 SideEffect

> 在计算机科学中，函数副作用（side effect）指当调用函数时，除了返回可能的函数值之外，还对主调用函数产生附加的影响。例如修改全局变量（函数外的变量），修改参数，向主调方的终端、管道输出字符或改变外部存储信息等。
>
> <p align="right">—— <a href="https://zh.wikipedia.org/wiki/%E5%89%AF%E4%BD%9C%E7%94%A8_(%E8%AE%A1%E7%AE%97%E6%9C%BA%E7%A7%91%E5%AD%A6)">WikiPedia 副作用_(计算机科学)</a></p>

## 为什么需要在 PaddleSOT 中使用 SideEffect

我们先来看一个demo, 我们可以看到此时的的`SOT`并不能准确的还原`global`并产生副作用.

```python
from sot.translate import symbolic_translate

global_x = 1

def foo():
    global global_x
    global_x = global_x + global_x
    return global_x


def main():
    dygraph_out = foo
    symbolic_translate_out = symbolic_translate(foo)

    print("symbolic_translate_out:", symbolic_translate_out()) # symbolic_translate_out: 1
    print("symbolic_translate_out:", symbolic_translate_out()) # symbolic_translate_out: 1
    print("dygraph_out:", dygraph_out()) # dygraph_out: 2
    print("dygraph_out:", dygraph_out()) # dygraph_out: 4
```

原生字节码:

```bash
 10           0 LOAD_GLOBAL              0 (global_x)
              2 LOAD_GLOBAL              0 (global_x)
              4 BINARY_ADD
              6 STORE_GLOBAL             0 (global_x)

 11           8 LOAD_GLOBAL              0 (global_x)
             10 RETURN_VALUE
```

转写后字节码:

```bash
  8           0 LOAD_GLOBAL              1 (paddle_set_eval_frame_fn)
              2 LOAD_CONST               0 (None)
              4 CALL_FUNCTION            1
              6 STORE_FAST               0 (___old_eval_frame)
              8 LOAD_GLOBAL              2 (__compiled_fn_dummy_func)
             10 BUILD_TUPLE              0
             12 CALL_FUNCTION            1
             14 UNPACK_SEQUENCE          0
             16 LOAD_GLOBAL              0 (global_x)
             18 LOAD_GLOBAL              1 (paddle_set_eval_frame_fn)
             20 LOAD_FAST                0 (___old_eval_frame)
             22 CALL_FUNCTION            1
             24 POP_TOP
             26 RETURN_VALUE
```


## 如何实现 SideEffect

其实实现起来也非常简单, 我们只需要重新把数据通过`SideEffect`, 机制重新给到python的栈结构上就能保证数据的准确性

转写后字节码:

```bash
  8           0 LOAD_GLOBAL              1 (paddle_set_eval_frame_fn)
              2 LOAD_CONST               0 (None)
              4 CALL_FUNCTION            1
              6 STORE_FAST               0 (___old_eval_frame)
              8 LOAD_GLOBAL              2 (__compiled_fn_dummy_func)
             10 BUILD_TUPLE              0
             12 CALL_FUNCTION            1
             14 UNPACK_SEQUENCE          0
             16 LOAD_CONST               1 (4)
             18 LOAD_CONST               1 (4)                  # <--- 重新load一次数据
             20 STORE_GLOBAL             0 (global_x)           # <--- 重新store一次数据
             22 LOAD_GLOBAL              1 (paddle_set_eval_frame_fn)
             24 LOAD_FAST                0 (___old_eval_frame)
             26 CALL_FUNCTION            1
             28 POP_TOP
             30 RETURN_VALUE
```

## 如何知道需要重新加载哪些数据呢 ？

这里是通过`STORE_GLOBAL`这个字节码来判断是否更新数据的，只有当`global`变量被更新的时候，我们才会重新加载数据. 

当运行到`STORE_GLOBAL`时会将`GlobalVariable`中原有的数据更新, 在更新的同时`GlobalVariable`中的数据域`MutableDictLikeData`会记录下来更新的数据, 以及版本信息, 以便后续重新加载数据.

## 如何重新加载数据呢 ？

在`FunctionGraph`类中的`restore_side_effects`方法中实现副作用机制的还原, 通过`MutableDictLikeData`中的数据来还原`GlobalVariable`中的数据, 以及版本信息.

```python
if isinstance(var, GlobalVariable):
    # 根据STORE_GLOBAL记录的value值进行_reconstruct还原数据
    # LOAD_CONST or LOAD_FAST
    for record in var.proxy.get_last_records():
        if isinstance(record, (MutationSet, MutationNew)):
            record.value._reconstruct(self.pycode_gen)

    # 对其他需要副作用的Variable进行还原
    self.restore_side_effects(variables[1:])

    # STORE_GLOBAL
    for record in var.proxy.get_last_records()[::-1]:
        if isinstance(record, (MutationSet, MutationNew)):
            self.pycode_gen.gen_store_global(record.key)
        if isinstance(record, MutationDel):
            self.pycode_gen.gen_delete_global(record.key)
```

这里`store`应该要反着才能对应上`load`的顺序

```bash
load 1
load 2

下一个 var

store 2
store 1
```

至此，就完成了整个`global`副作用的实现.

## 参考链接

- [副作用_(计算机科学)](https://zh.wikipedia.org/wiki/%E5%89%AF%E4%BD%9C%E7%94%A8_(%E8%AE%A1%E7%AE%97%E6%9C%BA%E7%A7%91%E5%AD%A6))
- [Python Bytecodes](https://docs.python.org/3/library/dis.html)
- [PaddleSOT](https://github.com/PaddlePaddle/PaddleSOT)
- [PaddleSOT-SideEffect](https://github.com/PaddlePaddle/PaddleSOT/blob/develop/docs/design/side-effect.md)
- [实现pr](https://github.com/PaddlePaddle/PaddleSOT/pull/278)
