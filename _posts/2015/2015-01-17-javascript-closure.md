---
layout: post

title: 理解Javascript的闭包

category: web

tags: [ javascript , closure]

description:  本文主要分析 javascript的闭包原理，以此出发去理解函数式编程中的闭包。

published: false

---
**前言：一篇入门文章，从酷壳转载而来，[原文地址](http://coolshell.cn/articles/6731.html)**。Javascript中有几个非常重要的语言特性——对象、原型继承、闭包。其中闭包对于那些使用传统静态语言C/C++的程序员来说是一个新的语言特性。本文将以例子入手来介绍Javascript闭包的语言特性，并结合一点ECMAScript语言规范来使读者可以更深入的理解闭包。

注：**本文是入门文章，例子素材整理于网络，如果你是高手，欢迎针对文章提出技术性建议和意见。本文讨论的是Javascript，不想做语言对比，如果您对Javascript天生不适，请自行绕道。**

##什么是闭包
闭包是什么?闭包是Closure，这是静态语言所不具有的一个新特性。但是闭包也不是什么复杂到不可理解的东西，简而言之，闭包就是：


- 闭包就是函数的局部变量集合，只是这些局部变量在函数返回后会继续存在。
- 闭包就是函数的“堆栈”在函数返回后并不释放，我们也可以理解为这些函数堆栈并不在栈上分配而是在堆上分配
- 当在一个函数内定义另外一个函数就会产生闭包

上面的第二定义是第一个补充说明，抽取第一个定义的主谓宾——闭包是**函数的‘局部变量’集合**。只是这个局部变量是可以在函数返回后被访问。（这个不是官方定义，但是这个定义应该更有利于你理解闭包）

作为局部变量都可以被函数内的代码访问，这个和静态语言是没有差别。闭包的差别在于局部变变量可以在函数执行结束后仍然被函数外的代码访问。这意味着函数必须返回一个指向闭包的“引用”，或将这个”引用”赋值给某个外部变量，才能保证闭包中局部变量被外部代码访问。当然包含这个引用的实体应该是一个对象，因为在Javascript中除了基本类型剩下的就都是对象了。可惜的是，ECMAScript并没有提供相关的成员和方法来访问闭包中的局部变量。但是在ECMAScript中，函数对象中定义的**内部函数(inner function)**是可以直接访问外部函数的局部变量，通过这种机制，我们就可以以如下的方式完成对闭包的访问了。

```
function greeting(name) {
    var text = 'Hello ' + name; // local variable
    // 每次调用时，产生闭包，并返回内部函数对象给调用者
    return function() { alert(text); }
}
var sayHello=greeting("Closure");
sayHello()  // 通过闭包访问到了局部变量text
```
上述代码的执行结果是：Hello Closure，因为sayHello()函数在greeting函数执行完毕后，仍然可以访问到了定义在其之内的局部变量text。

好了，这个就是传说中闭包的效果，闭包在Javascript中有多种应用场景和模式，比如Singleton，Power Constructor等这些Javascript模式都离不开对闭包的使用。

##ECMAScript闭包模型

ECMAScript到底是如何实现闭包的呢？想深入了解的亲们可以获取[ECMAScript 规范进](http://www.ecma-international.org/publications/files/ECMA-ST/Ecma-262.pdf)行研究，我这里也只做一个简单的讲解，内容也是来自于网络。

在ECMAscript的脚本的函数运行时，每个函数关联都有一个执行上下文场景(Execution Context) ，这个执行上下文场景中包含三个部分

- 文法环境（The LexicalEnvironment）
- 变量环境（The VariableEnvironment）
- this绑定

其中第三点this绑定与闭包无关，不在本文中讨论。文法环境中用于解析函数执行过程使用到的变量标识符。我们可以将文法环境想象成一个对象，该对象包含了两个重要组件，环境记录(Enviroment Recode)，和外部引用(指针)。环境记录包含包含了函数内部声明的局部变量和参数变量，外部引用指向了外部函数对象的上下文执行场景。全局的上下文场景中此引用值为NULL。这样的数据结构就构成了一个单向的链表，每个引用都指向外层的上下文场景。

例如上面我们例子的闭包模型应该是这样，sayHello函数在最下层，上层是函数greeting，最外层是全局场景。如下图：
[](static/images/2015/closure.png)
