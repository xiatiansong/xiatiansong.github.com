---
layout: post

title: AngularJS基本知识点

category: web

tags: [ angularjs ]

description: 整理 AngularJS 相关的一些知识点，方便快速理解和入门 AngularJS。文中涉及的内容有：AngularJS 指令、控制器、模型和服务定义方法、路由定义等内容，不包括 AngularJS 的介绍、历史以及依赖注入等原理。

published: true

---

AngularJS 是一个 MV* 框架，最适于开发客户端的单页面应用。它不是个功能库，而是用来开发动态网页的框架。它专注于扩展 HTML 的功能，提供动态数据绑定（data binding），而且它能跟其它框架（如 JQuery 等）合作融洽。

# 1. 一个简单示例

通过下面的示例代码，可以运行一个简单的 AngularJS 应用：

```html
<!DOCTYPE html>
<html>
<body>

<div ng-app="">
  <p>在输入框中尝试输入：</p>
  <p>姓名：<input type="text" ng-model="name"></p>
  <p ng-bind="name"></p>
</div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/angular.js/1.3.8/angular.min.js"></script>

</body>
</html>
```

通过浏览器访问该页面，在输入框中输入的内容会立即显示在输入框下面。

**说明：**

- 当网页加载完毕，AngularJS 自动运行。
- `ng-app` 指令告诉 AngularJS ，div 元素是 AngularJS 应用程序的"所有者"，相当于是个作用域的概率。
- `ng-model` 指令把输入域的值绑定到应用程序变量 name。
- `ng-bind` 指令把应用程序变量 name 绑定到某个段落的 innerHTML。

# 2. AngularJS 指令

AngularJS 指令是扩展的 HTML 属性，带有前缀 `ng-`。

HTML5 允许扩展的（自制的）属性，以 `data-` 开头。AngularJS 属性以 `ng-`开头，但是您可以使用 `data-ng-` 来让网页对 HTML5 有效。

## 常见的指令

### ng-app 指令

ng-app 指令初始化一个 AngularJS 应用程序。

### ng-init 指令

ng-init 指令初始化应用程序数据，这个不常使用。通常情况下，不使用 ng-init。您将使用一个控制器或模块来代替它。

### ng-model 指令

ng-model 指令把元素值（比如输入域的值）绑定到应用程序。

### ng-bind 指令

ng-bind 指令把应用程序数据绑定到 HTML 视图。

示例：

```html
<div ng-app="">
  <p>在输入框中尝试输入：</p>
  <p>姓名：<input type="text" ng-model="name"></p>
  <p ng-bind="name"></p>
</div>
```

### ng-repeat 指令

ng-repeat 指令会重复一个 HTML 元素：

```html
<div ng-app="" ng-init="names=[
{name:'Jani',country:'Norway'},
{name:'Hege',country:'Sweden'},
{name:'Kai',country:'Denmark'}]">

<p>循环对象：</p>
  <ul>
    <li ng-repeat="x in names">
      {{ x.name + ', ' + x.country }}
    </li>
  </ul>
</div>
```

除此之外，它还提供了几个变量可供使用：

- `$index` 当前索引
- `$first` 是否为头元素
- `$middle` 是否为非头非尾元素
- `$last` 是否为尾元素

## 样式相关的指令

### ng-class

ng-class用来给元素绑定类名，其表达式的返回值可以是以下三种：

- 类名字符串，可以用空格分割多个类名，如 ‘class1 class2’；
- 类名数组，数组中的每一项都会层叠起来生效；
- 一个名值对应的map，其键值为类名，值为boolean类型，当值为true时，该类会被加在元素上。

与 ng-class 相近的，ng 还提供了ng-class-odd、ng-class-even 两个指令，用来配合 ng-repeat 分别在奇数列和偶数列使用对应的类。这个用来在表格中实现隔行换色再方便不过了。

### ng-style

ng-style 用来绑定元素的 css 样式，其表达式的返回值为一个 js 对象，键为 css 样式名，值为该样式对应的合法取值。用法比较简单：

```html
$scope.style = {color:'red'};　

<div ng-style="{color:'red'}">ng-style测试</div>
<div ng-style="style">ng-style测试</div>
```

### ng-show、ng-hide、ng-switch

对于比较常用的元素显隐控制，ng 也做了封装，ng-show 和 ng-hide 的值为 boolean 类型的表达式，当值为 true 时，对应的 show 或 hide 生效。框架会用 `display:block` 和 `display:none` 来控制元素的显隐。

示例：

```html
<div ng-app="">
    <div ng-show="true">1</div>
    <div ng-show="false">2</div>
    <div ng-hide="true">3</div>
    <div ng-hide="false">4</div>
</div>
```

后一个 ng-switch 是根据一个值来决定哪个节点显示，其它节点移除：

```html
<div ng-init="a=2">
    <ul ng-switch on="a">
          <li ng-switch-when="1">1</li>
          <li ng-switch-when="2">2</li>
          <li ng-switch-default>other</li>
    </ul>
</div>
```

## 事件指令

事件相关的指令有：

- ng-change
- ng-click
- ng-dblclick
- ng-mousedown
- ng-mouseenter
- ng-mouseleave
- ng-mousemove
- ng-mouseover
- ng-mouseup
- ng-submit

对于事件对象本身，在函数调用时可以直接使用 $event 进行传递：

```html
<p ng-click="click($event)">点击</p>
<p ng-click="click($event.target)">点击</p>

$scope.click = function($event){
         alert($event.target);
         //……………………
}　　
```

## 表单指令

表单控件类的模板指令，最大的作用是它预定义了需要绑定的数据的格式。这样，就可以对于既定的数据进行既定的处理。

### form

 ng 对 form 这个标签作了包装，对应的指令是 ng-form。

 从 ng 的角度来说， form 标签，是一个模板指令，也创建了一个 `FormController` 的实例。这个实例就提供了相应的属性和方法。同时，它里面的控件也是一个 `NgModelController` 实例。

很重要的一点， form 的相关方法要生效，必须为 form 标签指定 name 和 ng-controller ，并且每个控件都要绑定一个变量。 form 和控件的名字，即是 $scope 中的相关实例的引用变量名。

```html
<form name="test_form" ng-controller="TestCtrl">
  <input type="text" name="a" required ng-model="a"  />
  <span ng-click="see()">{{ test_form.$valid }}</span>
</form>

var TestCtrl = function($scope){
  $scope.see = function(){
    console.log($scope.test_form);
    console.log($scope.test_form.a);
  }
}
```

除去对象的方法与属性， form 这个标签本身有一些动态类可以使用：

- `ng-valid` 当表单验证通过时的设置
- `ng-invalid` 当表单验证失败时的设置
- `ng-pristine` 表单的未被动之前拥有
- `ng-dirty` 表单被动过之后拥有

form 对象的属性有：

- `$pristine` 表单是否未被动过
- `$dirty` 表单是否被动过
- `$valid` 表单是否验证通过
- `$invalid` 表单是否验证失败
- `$error` 表单的验证错误

其中的 $error 对象包含有所有字段的验证信息，及对相关字段的 NgModelController 实例的引用。它的结构是一个对象， key 是失败信息， required ， minlength 之类的， value 是对应的字段实例列表。

### input

input 控件的相关可用属性为：

- `name` 名字
- `ng-model` 绑定的数据
- `required` 是否必填
- `ng-required` 是否必填
- `ng-minlength` 最小长度
- `ng-maxlength` 最大长度
- `ng-pattern` 匹配模式
- `ng-change` 值变化时的回调

```html
<form name="test_form" ng-controller="TestCtrl">
  <input type="text" name="a" ng-model="a" required ng-pattern="/abc/" />
  <span ng-click="see()">{{ test_form.$error }}</span>
</form>
```

input 控件，它还有一些扩展，这些扩展有些有自己的属性：

- `input type="number" `多了 number 错误类型，多了 max ， min 属性。
- `input type="url" `多了 url 错误类型。
- `input type="email" `多了 email 错误类型。

### checkbox

是 input 的扩展，不过，它没有验证相关的东西，只有选中与不选中两个值：ng-true-value、ng-false-value:

```html
<form name="test_form" ng-controller="TestCtrl">
  <input type="checkbox" name="a" ng-model="a" ng-true-value="AA" ng-false-value="BB" />
  <span>{{ a }}</span>
</form>
```

### radio

也是 input 的扩展。和 checkbox 一样，但它只有一个值：

```html
<form name="test_form" ng-controller="TestCtrl">
  <input type="radio" name="a" ng-model="a" value="AA" />
  <input type="radio" name="a" ng-model="a" value="BB" />
  <span>{{ a }}</span>
</form>
```

### textarea

同 input

### select

它里面的一个叫做 `ng-options` 的属性用于数据呈现。

```html
<form name="test_form" ng-controller="TestCtrl" ng-init="o=[0,1,2,3]; a=o[1];">
    <select ng-model="a" ng-options="x for x in o">
      <option value="">可以加这个空值</option>
    </select>
</form>
```

在 $scope 中， select 绑定的变量，其值和普通的 value 无关，可以是一个对象：

```html
<form name="test_form" ng-controller="TestCtrl"
    ng-init="o=[{name: 'AA'}, {name: 'BB'}]; a=o[1];">
    <select ng-model="a" ng-options="x.name for x in o" />
</form>
```

显示与值分别指定， `x.v as x.name for x in o` ：

```html
<form name="test_form" ng-controller="TestCtrl"
    ng-init="o=[{name: 'AA', v: '00'}, {name: 'BB', v: '11'}]; a=o[1].v;">
    <select ng-model="a" ng-options="x.v as x.name for x in o" />
</form>
```

加入分组的， `x.name group by x.g for x in o` ：

```html
<form name="test_form" ng-controller="TestCtrl"
    ng-init="o=[{name: 'AA', g: '00'}, {name: 'BB', g: '11'}, {name: 'CC', g: '00'}]; a=o[1];">
    <select ng-model="a" ng-options="x.name group by x.g for x in o" />
</form>
  ```

分组了还分别指定显示与值的， x.v as x.name group by x.g for x in o ：

```html
<form name="test_form" ng-controller="TestCtrl" ng-init="o=[{name: 'AA', g: '00', v: '='}, {name: 'BB', g: '11', v: '+'}, {name: 'CC', g: '00', v: '!'}]; a=o[1].v;">
    <select ng-model="a" ng-options="x.v as x.name group by x.g for x in o" />
</form>
```

如果参数是对象的话，基本也是一样的，只是把遍历的对象改成 (key, value) ：

```html
<form name="test_form" ng-controller="TestCtrl" ng-init="o={a: 0, b: 1}; a=o.a;">
    <select ng-model="a" ng-options="k for (k, v) in o" />
</form>

<form name="test_form" ng-controller="TestCtrl"
    ng-init="o={a: {name: 'AA', v: '00'}, b: {name: 'BB', v: '11'}}; a=o.a.v;">
    <select ng-model="a" ng-options="v.v as v.name for (k, v) in o" />
</form>

<form name="test_form" ng-controller="TestCtrl"
    ng-init="o={a: {name: 'AA', v: '00', g: '=='}, b: {name: 'BB', v: '11', g: '=='}}; a=o.a;">
    <select ng-model="a" ng-options="v.name group by v.g for (k, v) in o" />
</form>

<form name="test_form" ng-controller="TestCtrl"
    ng-init="o={a: {name: 'AA', v: '00', g: '=='}, b: {name: 'BB', v: '11', g: '=='}}; a=o.a.v;">
    <select ng-model="a" ng-options="v.v as v.name group by v.g for (k, v) in o" />
</form>
```

还有一些表单控件功能相关的指令：

- `ng-src`  src 属性
- `ng-href`  href 属性
- `ng-checked` 控制 radio 和 checkbox 的选中状态
- `ng-selected` 控制下拉框的选中状态
- `ng-disabled` 控制失效状态
- `ng-multiple` 控制多选
- `ng-readonly` 控制只读状态

以上指令的取值均为 boolean 类型，当值为 true 时相关状态生效，道理比较简单就不多做解释。

**注意：** 上面的这些只是单向绑定，即只是从数据到模板，不能反作用于数据。要双向绑定，还是要使用 ng-model 。

# 3. AngularJS 过滤器

过滤器（filter）正如其名，作用就是接收一个输入，通过某个规则进行处理，然后返回处理后的结果。主要用在数据的格式化上，例如获取一个数组中的子集，对数组中的元素进行排序等。过滤器通常是伴随标记来使用的，将你 model 中的数据格式化为需要的格式。表单的控制功能主要涉及到数据验证以及表单控件的增强。

## 内置过滤器

ng 内置了一些过滤器，它们是：
currency(货币)、date(日期)、filter(子串匹配)、json(格式化json对象)、limitTo(限制个数)、lowercase(小写)、uppercase(大写)、number(数字)、orderBy(排序)。

过滤器使用示例：

{% highlight javascript %}
{% raw %}
// 使用currency可以将数字格式化为货币，默认是美元符号，你可以自己传入所需的符号
{{num | currency : '￥'}}

// 参数用来指定所要的格式，y M d h m s E 分别表示 年 月 日 时 分 秒 星期，你可以自由组合它们。也可以使用不同的个数来限制格式化的位数。另外参数也可以使用特定的描述性字符串，例如“shortTime”将会把时间格式为12:05 pm这样的。
{{date | date : 'yyyy-MM-dd hh:mm:ss EEEE'}}

$scope.func = function(e){return e.age>4;}{{ childrenArray | filter : 'a' }}

// filter 过滤器从数组中选择一个子集：
{{ childrenArray | filter : 'a' }} //匹配属性值中含有a的
{{ childrenArray | filter : 4 }}  //匹配属性值中含有4的
{{ childrenArray | filter : {name : 'i'} }} //参数是对象，匹配name属性中含有i的
{{childrenArray | filter : func }}  //参数是函数　

// json过滤器可以把一个js对象格式化为json字符串
{{ jsonTest | json}}

// 列表截取 limitTo ，支持正负数
{{ childrenArray | limitTo : 2 }} 

// number过滤器可以为一个数字加上千位分割，像这样，123,456,789。同时接收一个参数，可以指定float类型保留几位小数：
{{ num | number : 2 }}

// 大小写 lowercase ， uppercase ：
{{ 'abc' | uppercase }}
{{ 'Abc' | lowercase }}


{{ childrenArray | orderBy : 'age' }}       //按age属性值进行排序，若是-age，则倒序
{{ childrenArray | orderBy : orderFunc }}   //按照函数的返回值进行排序
{{ childrenArray | orderBy : ['age','name'] }}  //如果age相同，按照name进行排序
{% endraw %}
{% endhighlight %}

## 过滤器使用方式

在模块中定义过滤器：

```javascript
var app = angular.module('Demo', [], angular.noop);
  app.filter('map', function(){
    var filter = function(input){
      return input + '...';
    };
    return filter;
  });
```

然后，在模板中使用：

{% highlight html %}
{% raw %}
<p>示例数据: {{ a | map }}</p>
{% endraw %}
{% endhighlight %}

# 4. AngularJS Ajax

$http 服务是 AngularJS 的核心服务之一，它帮助我们通过 XMLHttpRequest 对象或 JSONP 与远程 HTTP 服务进行交流。

$http 服务是这样一个函数：它接受一个设置对象，其中指定了如何创建 HTTP 请求；它将返回一个 promise 对象，其中提供两个方法： success 方法和 error方法。

```javascript
$http.get({url:"/xxx.action"}).success(function(data){
    alert(data);
}).error(function(){
    alert("error");
});
```

$http 接受的配置项有：

- `method` 方法
- `url` 路径
- `params` GET请求的参数
- `data` post请求的参数
- `headers` 头
- `transformRequest` 请求预处理函数
- `transformResponse` 响应预处理函数
- `cache` 缓存
- `timeout` 超时毫秒，超时的请求会被取消
- `withCredentials` 跨域安全策略的一个东西

其中的 transformRequest 和 transformResponse 及 headers 已经有定义的，如果自定义则会覆盖默认定义

对于几个标准的 HTTP 方法，有对应的 shortcut ：

```javascript
$http.delete(url, config)
$http.get(url, config)
$http.head(url, config)
$http.jsonp(url, config)
$http.post(url, data, config)
$http.put(url, data, config)
```

注意其中的 JSONP 方法，在实现上会在页面中添加一个 script 标签，然后放出一个 GET 请求。你自己定义的，匿名回调函数，会被 ng 自已给一个全局变量。在定义请求，作为 GET 参数，你可以使用 `JSON_CALLBACK` 这个字符串来暂时代替回调函数名，之后 ng 会为你替换成真正的函数名：

```javascript
var p = $http({
    method: 'JSONP',
    url: '/json',
    params: {callback: 'JSON_CALLBACK'}
});
p.success(function(response, status, headers, config){
    console.log(response);
    $scope.name = response.name;
});
```

$http 有两个属性：

- `defaults` 请求的全局配置
- `pendingRequests` 当前的请求队列状态

```javascript
$http.defaults.transformRequest = function(data){
    console.log('here'); return data;}

console.log($http.pendingRequests);
```

# 5. AngularJS 控制器

AngularJS 应用程序被控制器控制，控制器是 JavaScript 对象，由标准的 JavaScript 对象的构造函数 创建。

ng-controller 指令定义了应用程序控制器，给所在的 DOM 元素创建了一个新的 $scope 对象，并将这个 $scope 对象包含进外层 DOM 元素的 $scope 对象里。

示例如下：

{% highlight html %}
{% raw %}
<div ng-app="" ng-controller="personController">

名： <input type="text" ng-model="person.firstName"><br>
姓： <input type="text" ng-model="person.lastName"><br>
<br>
姓名： {{fullName()}}

</div>

<script>
function personController($scope) {
    $scope.person = {
        firstName: "John",
        lastName: "Doe",
     };
     $scope.fullName = function() {
         var x;
         x = $scope.person; 
         return x.firstName + " " + x.lastName;
     };
}
</script>
{% endraw %}
{% endhighlight %}

$scope 是一个把 view（一个DOM元素）连结到 controller 上的对象。在我们的 MVC 结构里，这个 $scope 将成为 model，它提供一个绑定到DOM元素（以及其子元素）上的excecution context。

尽管听起来有点复杂，但 $scope 实际上就是一个JavaScript 对象，controller 和 view 都可以访问它，所以我们可以利用它在两者间传递信息。在这个 $scope 对象里，我们既存储数据，又存储将要运行在view上的函数。

每一个 Angular 应用都会有一个 $rootScope。这个 $rootScope 是最顶级的 scope，它对应着含有 ng-app 指令属性的那个 DOM 元素

所有scope都遵循原型继承（prototypal inheritance），这意味着它们都能访问父scope们。

# 6. AngularJS 模块

 AngularJS 本身的一个默认模块叫做 ng ，它提供了 $http ， $q 等等服务。

服务只是模块提供的多种机制中的一种，其它的还有命令（ directive ），过滤器（ filter ），及其它配置信息。

然后在额外的 js 文件中有一个附加的模块叫做 ngResource ， 它提供了一个 $resource 服务。

## 定义模块

定义模块的方法是使用 angular.module 。调用时声明了对其它模块的依赖，并定义了“初始化”函数。

```javascript
  var my_module = angular.module('MyModule', [], function(){
      console.log('here');
  });
```

这段代码定义了一个叫做 MyModule 的模块， my_module 这个引用可以在接下来做其它的一些事，比如定义服务。

## 定义服务

ng的服务是这样定义的：

>Angular services are singletons objects or functions that carry out specific tasks common to web apps.

- 它是一个单例对象或函数，对外提供特定的功能。
- 首先是一个单例，即无论这个服务被注入到任何地方，对象始终只有一个实例。
- 其次这与我们自己定义一个function然后在其他地方调用不同，因为服务被定义在一个模块中，所以其使用范围是可以被我们管理的。ng的避免全局变量污染意识非常强。

ng提供了很多内置的服务，可以到API中查看 <http://docs.angularjs.org/api/>。如同指令一样，系统内置的服务以$开头，我们也可以自己定义一个服务。

在这里呢，就要先介绍一下叫 provider 的东西。简单来说， provider 是被 `注入控制器` 使用的一个对象，注入机制通过调用一个 provider 的 $get() 方法，把得到的东西作为参数进行相关调用（比如把得到的服务作为一个 Controller 的参数）。

在这里 `服务` 的概念就比较不明确，对使用而言，服务仅指 $get() 方法返回的东西，但是在整体机制上，服务又要指提供了 $get() 方法的整个对象。

```javascript
  //这是一个provider
  var pp = function(){
    this.$get = function(){
      return {'haha': '123'};
    }
  }
  
  //我在模块的初始化过程当中, 定义了一个叫 PP 的服务
  var app = angular.module('Demo', [], function($provide){
    $provide.provider('PP', pp);
  });
  
  //PP服务实际上就是 pp 这个 provider 的 $get() 方法返回的东西
  app.controller('TestCtrl',
    function($scope, PP){
      console.log(PP);
    }
  );
```

ng 还有相关的 shortcut，**第一个是 factory 方法**，由 $provide 提供， module 的 factory 是一个引用，作用一样。这个方法直接把一个函数当成是一个对象的 $get() 方法，这样你就不用显式地定义一个 provider 了：

```javascript
var app = angular.module('Demo', [], function($provide){
    $provide.factory('PP', function(){
        return {'hello': '123'};
    });
});
app.controller('TestCtrl', function($scope, PP){ console.log(PP) });
```

在 module 中使用：

```javascript
var app = angular.module('Demo', [], function(){ });
app.factory('PP', function(){return {'abc': '123'}});
app.controller('TestCtrl', function($scope, PP){ console.log(PP) });
```

**第二个是 service 方法**，也是由 $provide 提供， module 中有对它的同名引用。 service 和 factory 的区别在于，前者是要求提供一个“构造方法”，后者是要求提供 $get() 方法。意思就是，前者一定是得到一个 object ，后者可以是一个数字或字符串。它们的关系大概是：

```javascript
var app = angular.module('Demo', [], function(){ });
app.service = function(name, constructor){
    app.factory(name, function(){
      return (new constructor());
    });
}
```

service 方法的使用就很简单了：

```javascript
var app = angular.module('Demo', [], function(){ });
app.service('PP', function(){
    this.abc = '123';
});
app.controller('TestCtrl', function($scope, PP){ console.log(PP) });
```

## 引入模块并使用服务

结合上面的 `定义模块` 和 `定义服务`，我们可以方便地组织自己的额外代码：

```javascript
// 定义服务
angular.module('MyModule', [], function($provide){
    $provide.factory('S1', function(){
      return 'I am S1';
    });
    $provide.factory('S2', function(){
      return {see: function(){return 'I am S2'}}
    });
});

// 调用服务
var app = angular.module('Demo', ['MyModule'], angular.noop);
app.controller('TestCtrl', function($scope, S1, S2){
    console.log(S1)
    console.log(S2.see())
});
```

#  7. 附加模块 ngResource

ngResource 这个是 ng 官方提供的一个附加模块。`附加` 的意思就是，如果你打算用它，那么你需要引入一人单独的 js 文件，然后在声明“根模块”时注明依赖的 ngResource 模块，接着就可以使用它提供的 $resource 服务了。

$resource 服务主要是包装了 AJAX  的调用，使用 $resource 需要先定义“资源”，也就是先定义一些 HTTP 请求。

TODO

# 8. AngularJS 路由

ng的路由(ngRoute)是一个单独的模块，包含以下内容：

- 服务 `$routeProvider` 用来定义一个路由表，即地址栏与视图模板的映射
- 服务 `$routeParams` 保存了地址栏中的参数，例如 `{id : 1, name : 'tom'}`
- 服务 `$route` 完成路由匹配，并且提供路由相关的属性访问及事件，如访问当前路由对应的 controller
- 指令 `ngView` 用来在主视图中指定加载子视图的区域

## 定义路由

第一步：引入文件和依赖

ngRoute 也是一个附件模块，故需要在页面上引入 `angular-route.min.js` 并在模块中注入对 ngRoute 的依赖，如下：

```javascript
var app = angular.module('MyApp', ['ngRoute']);
```

第二步：定义路由表

$routeProvider 提供了定义路由表的服务，它有两个核心方法：`when(path,route)` 和 `otherwise(params)`，先看一下核心中的核心 when(path,route)方法。

`when(path,route)` 方法接收两个参数:

- path 是一个 string 类型，表示该条路由规则所匹配的路径，它将与地址栏的内容($location.path)值进行匹配。如果需要匹配参数，可以在 path 中使用冒号加名称的方式，如：path为 `/show/:name`，如果地址栏是 `/show/tom` ，那么参数 name 和所对应的值 tom 便会被保存在 $routeParams 中，像这样：`{name : tom}`。我们也可以用 `*` 进行模糊匹配，如：`/show*/:name` 将匹配`/showInfo/tom`。
- route 参数是一个 object，用来指定当 path 匹配后所需的一系列配置项，包括以下内容：
 - `controller` function 或 string 类型。在当前模板上执行的 controller 函数，生成新的 scope；
 - `controllerAs` string 类型，为 controller 指定别名；
 - `template` string 或 function 类型，视图所用的模板，这部分内容将被 ngView 引用；
 - `templateUrl` string 或 function 类型，当视图模板为单独的 html 文件或是使用了 `<script type="text/ng-template">`定义模板时使用；
 - `resolve` 指定当前 controller 所依赖的其他模块；
 - `redirectTo` 重定向的地址。

第三步：在主视图模板中指定加载子视图的位置

只需在模板中简单的使用此 ngView 指令:

```html
<div ng-view></div>
```

# 9. 参考文章

- [AngularJS 教程](http://www.w3cschool.cc/angularjs/angularjs-tutorial.html)
- [angularjs学习总结 详细教程](http://blog.csdn.net/yy374864125/article/details/41349417)
- [AngularJS学习笔记](http://www.zouyesheng.com/angular.html#toc34)
