---
layout: post

title:  Spring源码整体架构

description:  从这篇文章开始，我讲开始阅读并介绍 Spring 源码的设计思想，希望能改对 Spring 框架有一个初步的全面的认识，并且学习其架构设计方面的一些理念和方法。

keywords:  spring

category:  java

tags: [spring]

published: true

---


# 前言

Spring 是一个开源框架，是为了解决企业应用程序开发复杂性而创建的。框架的主要优势之一就是其分层架构，分层架构允许您选择使用哪一个组件，同时为 J2EE 应用程序开发提供集成的框架。

从这篇文章开始，我讲开始阅读并介绍 Spring 源码的设计思想，希望能改对 Spring 框架有一个初步的全面的认识，并且学习其架构设计方面的一些理念和方法。

Spring 源码地址：<https://github.com/spring-projects/spring-framework>

# 概述

## Spring的整体架构

Spring 总共有十几个组件，其中核心组件只有三个：Core、Context 和 Beans。以下是 Spring3的总体架构图。

![](http://xiaotian120.qiniudn.com/images/spring/spring3-modules.png)

组成 Spring 框架的每个模块（或组件）都可以单独存在，或者与其他一个或多个模块联合实现。每个模块的功能如下：

- 核心容器：核心容器提供 Spring 框架的基本功能。核心容器的主要组件是 BeanFactory，它是工厂模式的实现。BeanFactory 使用控制反转 （IOC） 模式将应用程序的配置和依赖性规范与实际的应用程序代码分开。
- Spring 上下文：Spring 上下文是一个配置文件，向 Spring 框架提供上下文信息。Spring 上下文包括企业服务，例如：JNDI、EJB、电子邮件、国际化、校验和调度功能。
- Spring AOP：通过配置管理特性，Spring AOP 模块直接将面向方面的编程功能集成到了 Spring 框架中。所以，可以很容易地使 Spring 框架管理的任何对象支持 AOP。Spring AOP 模块为基于 Spring 的应用程序中的对象提供了事务管理服务。通过使用 Spring AOP，不用依赖 EJB 组件，就可以将声明性事务管理集成到应用程序中。
- Spring DAO：JDBC DAO 抽象层提供了有意义的异常层次结构，可用该结构来管理异常处理和不同数据库供应商抛出的错误消息。异常层次结构简化了错误处理，并且极大地降低了需要编写的异常代码数量（例如打开和关闭连接）。Spring DAO 的面向 JDBC 的异常遵从通用的 DAO 异常层次结构。
- Spring ORM：Spring 框架插入了若干个 ORM 框架，从而提供了 ORM 的对象关系工具，其中包括 JDO、Hibernate 和 iBatis SQL Map。所有这些都遵从 Spring 的通用事务和 DAO 异常层次结构。
- Spring Web 模块：Web 上下文模块建立在应用程序上下文模块之上，为基于 Web 的应用程序提供了上下文。所以，Spring 框架支持与 Jakarta Struts 的集成。Web 模块还简化了处理多部分请求以及将请求参数绑定到域对象的工作。
- Spring MVC 框架：MVC 框架是一个全功能的构建 Web 应用程序的 MVC 实现。通过策略接口，MVC 框架变成为高度可配置的，MVC 容纳了大量视图技术，其中包括 JSP、Velocity、Tiles、iText 和 POI。

从下图（该图来自[SPRING 3.2.X 源代码分析之二: SPRING源码的包结构](http://www.javastar.org/?p=847)）可以看出 Spring 各个模块之间的依赖关系。

![](http://xiaotian120.qiniudn.com/images/spring/spring-packages.jpg)

从图中可以看出，IOC 的实现包 spring-beans 和 AOP 的实现包 spring-aop 也是整个框架的基础，而 spring-core 是整个框架的核心，基础的功能都在这里。

在此基础之上，spring-context 提供上下文环境，为各个模块提供粘合作用。

在 spring-context 基础之上提供了 spring-tx 和 spring-orm包，而web部分的功能，都是要依赖spring-web来实现的。

## Spring 的设计理念

Spring 是面向 Bean 的编程（BOP,Bean Oriented Programming），Bean 在 Spring 中才是真正的主角。Bean 在 Spring 中作用就像 Object 对 OOP 的意义一样，没有对象的概念就像没有面向对象编程，Spring 中没有 Bean 也就没有 Spring 存在的意义。Spring 提供了 IOC 容器通过配置文件或者注解的方式来管理对象之间的依赖关系。

控制反转模式（也称作依赖性介入）的基本概念是：不创建对象，但是描述创建它们的方式。在代码中不直接与对象和服务连接，但在配置文件中描述哪一个组件需要哪一项服务。容器 （在 Spring 框架中是 IOC 容器） 负责将这些联系在一起。

在典型的 IOC 场景中，容器创建了所有对象，并设置必要的属性将它们连接在一起，决定什么时间调用方法。

## 面向方面的编程

面向方面的编程，即 AOP，是一种编程技术，它允许程序员对横切关注点或横切典型的职责分界线的行为（例如日志和事务管理）进行模块化。AOP 的核心构造是方面，它将那些影响多个类的行为封装到可重用的模块中。

AOP 和 IOC 是补充性的技术，它们都运用模块化方式解决企业应用程序开发中的复杂问题。在典型的面向对象开发方式中，可能要将日志记录语句放在所有方法和 Java 类中才能实现日志功能。在 AOP 方式中，可以反过来将日志服务模块化，并以声明的方式将它们应用到需要日志的组件上。当然，优势就是 Java 类不需要知道日志服务的存在，也不需要考虑相关的代码。所以，用 Spring AOP 编写的应用程序代码是松散耦合的。

AOP 的功能完全集成到了 Spring 事务管理、日志和其他各种特性的上下文中。

## IOC 容器

Spring 设计的核心是 org.springframework.beans 包，它的设计目标是与 JavaBean 组件一起使用。这个包通常不是由用户直接使用，而是由服务器将其用作其他多数功能的底层中介。下一个最高级抽象是 BeanFactory 接口，它是工厂设计模式的实现，允许通过名称创建和检索对象。BeanFactory 也可以管理对象之间的关系。

BeanFactory 支持两个对象模型。

- 单例。 模型提供了具有特定名称的对象的共享实例，可以在查询时对其进行检索。Singleton 是默认的也是最常用的对象模型。对于无状态服务对象很理想。
- 原型。 模型确保每次检索都会创建单独的对象。在每个用户都需要自己的对象时，原型模型最适合。

bean 工厂的概念是 Spring 作为 IOC 容器的基础。IOC 将处理事情的责任从应用程序代码转移到框架。正如我将在下一个示例中演示的那样，Spring 框架使用 JavaBean 属性和配置数据来指出必须设置的依赖关系

## Spring4 的系统架构图

![](http://xiaotian120.qiniudn.com/images/spring/spring4-modules.png)

Spring 4.0.x对比Spring3.2.x的系统架构变化（以下文字摘抄于[SPRING 3.2.X 源代码分析之三: SPRING源码的整体架构分析](http://www.javastar.org/?p=872)）:

> 从图中可以看出，总体的层次结构没有太大变化，变化的是 Spring 4.0.3去掉了 struts 模块(spring-struts包)。现在的 Spring mvc的确已经足够优秀了，大量的 web 应用均已经使用了 Spring mvc。而 struts1.x 的架构太落后了，struts2.x 是 struts 自身提供了和 Spring 的集成包，但是由于之前版本的 struts2 存在很多致命的安全漏洞，所以，大大影响了其使用度，好在最新的2.3.16版本的 struts 安全有所改善，希望不会再出什么大乱子。
>
> web 部分去掉了 struts 模块，但是增加 WebSocket 模块(spring-websocket包)，增加了对 WebSocket、SockJS 以及 STOMP 的支持，它与 JSR-356 Java WebSocket API 兼容。另外，还提供了基于 SockJS（对 WebSocket 的模拟）的回调方案，以适应不支持 WebSocket 协议的浏览器。
>
> 同时，增加了 messaging 模块(spring-messaging)，提供了对 STOMP 的支持，以及用于路由和处理来自 WebSocket 客户端的 STOMP 消息的注解编程模型。spring-messaging 模块中还 包含了 Spring Integration 项目中的核心抽象类，如 Message、MessageChannel、MessageHandler。
> 
> 如果去看源代码的话，还可以发现还有一个新增的包，加强了 beans 模块，就是 spring-beans-groovy。应用可以部分或完全使用 Groovy 编写。借助于 Spring 4.0，能够使用 Groovy DSL 定义外部的 Bean 配置，这类似于 XML Bean 声明，但是语法更为简洁。使用Groovy还能够在启动代码中直接嵌入Bean的声明。

还有一些：

- 删除过时的包和方法。具体API变动可以参考[变动报告](http://docs.spring.io/spring-framework/docs/3.2.4.RELEASE_to_4.0.0.RELEASE/)，第三方类库至少使用2010/2011年发布的版本，尤其是Hibernate 3.6+, EhCache 2.1+, Quartz 1.8+, Groovy 1.8+, and Joda-Time 2.0+。Hibernate Validator要求使用4.3+，Jackson 2.0+。
- Java 8支持。当然也支持Java6和Java7，但最好在使用Spring框架3.X或4.X时，将JDK升级到Java7，因为有些版本至少需要Java7。
- Java EE 6和7。使用Spring4.x时Java EE版本至少要6或以上，且需要JPA 2.0和Servlet 3.0 的支持，所以服务器，web容器需要做相应的升级。一个更具前瞻性的注意是，Spring4.0支持J2EE 7的适用级规范，比如JMS 2.0， JTA 1.2， JPA 2.1， Bean Validation 1.1和JSR-236并发工具包，在选择这些jar包时需要注意版本。
- 使用Groovy DSL定义外部Bean。
- 核心容器提升。
 - 1、支持Bean的泛型注入，比如：`@Autowired Repository<Customer> customerRepository`
 - 2、使用元注解开发暴露指定内部属性的自定义注解。
 - 3、通过 `@Ordered` 注解或`Ordered` 接口对注入集合或数组的 Bean 进行排序。
 - 4、`@Lazy` 注解可以用在注入点或 `@Bean` 定义上。
 - 5、为开发者引入 `@Description` 注解。
 - 6、引入 `@Conditional` 注解进行有条件的 Bea n过滤。
 - 7、基于 CGLIB 的代理类不需要提供默认构造器，因为 Spring 框架将 CGLIB 整合到内部了。
 - 8、框架支持时区管理，比如 LocalContext。
- Web提升。
 - 1、增加新的 `@RestController` 注解，这样就不需要在每个 `@RequestMapping` 方法中添加 `@ResponseBody` 注解。
 - 2、添加 AsyncRestTemplate，在开发 REST 客户端时允许非阻塞异步支持。
 - 3、为 Spring MVC 应用程序开发提供全面的时区支持。
- WebSocket，SockJS 和 STOMP 消息。
- 测试提升。
 - 1、spring-test 模块里的几乎所有注解都能被用做元注解去创建自定义注解，来减少跨测试集时的重复配置。
 - 2、活跃的 bean 定义配置文件可以编程方式解析。
 - 3、spring-core 模块里引入一个新的 SocketUtils 类，用于扫描本地可使用的 TCP 和 UDP 服务端口。一般用于测试需要 socket 的情况，比如测试开启内存 SMTP 服务，FTP 服务，Servlet 容器等。
 - 4、由于 Spring4.0 的原因，org.springframework.mock.web 包现在基于 Servlet 3.0 API。

# 阅读过程

因为 Spring 是分模块的，所以阅读 Spring 3.2.11 版本的源码过程打算先从最底层的模块开始，然后再由下向上分析每一个模块的实现过程。在阅读过程中，随着对代码的理解加深，也会重新阅读已经读过的代码。

大概的阅读顺序：

- spring-core：了解 Spring 提供哪些工具类以及一些基础的功能，如对资源文件的封装、对 Propertis 文件操作的封装、对 Environment 的封装等等。
- spring-context：通过分析 Spring 的启动方式，了解 Spring xml 文件的解析过程，bean 的初始化过程
- spring-orm
- spring-tx
- spring-web

注意：这里使用的Spring 版本是 3.2.11，下载地址在：<https://github.com/spring-projects/spring-framework/releases>

# 搭建测试环境

Spring 源码编译过程，这里不做说明。

为了测试简单，可以单独创建 java 项目，编写一些测试用例或者例子来测试 Spring 的功能。我使用的测试环境是：

- Idea 13
- Maven 3.0.5
- JDK1.6

生成 maven 项目命令：

```bash
$ mvn archetype:generate -DgroupId=com.javachen.spring.core -DartifactId=Spring3Example 
	-DarchetypeArtifactId=maven-archetype-quickstart -DinteractiveMode=false
```

转换成 idea 项目：

```bash
mvn idea:idea
```

然后，根据使用情况添加 Spring 的依赖包：

```xml
<project xmlns="http://maven.apache.org/POM/4.0.0" 
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
	http://maven.apache.org/maven-v4_0_0.xsd">
	<modelVersion>4.0.0</modelVersion>
	<groupId>com.javachen.spring.core</groupId>
	<artifactId>Spring3Example</artifactId>
	<packaging>jar</packaging>
	<version>1.0-SNAPSHOT</version>
	<name>Spring3Example</name>
	<url>http://maven.apache.org</url>
 
	<properties>
		<spring.version>3.2.11.RELEASE</spring.version>
	</properties>
 
	<dependencies>
 
		<!-- Spring 3 dependencies -->
		<dependency>
			<groupId>org.springframework</groupId>
			<artifactId>spring-core</artifactId>
			<version>${spring.version}</version>
		</dependency>
 
		<dependency>
			<groupId>org.springframework</groupId>
			<artifactId>spring-context</artifactId>
			<version>${spring.version}</version>
		</dependency>
 
	</dependencies>
</project>
```

记下来就可以编写测试类进行测试并关联 Spring 源代码跟踪调试代码。

# Spring 的一些教程

- <http://www.mkyong.com/tutorials/spring-tutorials/>
- <http://www.springbyexample.org/examples/index.html>
- <http://www.dzone.com/tutorials/java/spring/spring-tutorial/spring-tutorial.html>
- <http://viralpatel.net/blogs/category/spring/>

# 参考文章

- [Spring 框架的设计理念与设计模式分析](http://www.ibm.com/developerworks/cn/java/j-lo-spring-principle/)
- [Spring 系列: Spring 框架简介](http://www.ibm.com/developerworks/cn/java/wa-spring1/)
- [SPRING 3.2.X 源代码分析之二: SPRING源码的包结构](http://www.javastar.org/?p=847)
- [SPRING 3.2.X 源代码分析之三: SPRING源码的整体架构分析](http://www.javastar.org/?p=872)
