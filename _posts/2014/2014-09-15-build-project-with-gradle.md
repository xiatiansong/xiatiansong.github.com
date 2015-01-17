---
layout: post

title:  使用Gradle构建项目

description:  Gradle 是一款基于 Groovy 语言、免费开源的构建工具，它既保持了 Maven 的优点，又通过使用 Groovy 定义的 DSL 克服了 Maven 中使用 XML 繁冗以及不灵活的缺点。

keywords:  

category:  java

tags: [groovy,gradle,maven]

published: true

---


Gradle 是一款基于 Groovy 语言、免费开源的构建工具，它既保持了 Maven 的优点，又通过使用 Groovy 定义的 DSL 克服了 Maven 中使用 XML 繁冗以及不灵活的缺点。

Gradle 官方网站：<http://www.gradle.org/downloads>

# 安装

一种方式是从 [官方](http://www.gradle.org/downloads) 下载解压然后配置环境变量。

Mac 上安装：

```
$ brew install gradle
```

测试是否安装成功：

```
$ gradle -v
------------------------------------------------------------
Gradle 2.0
------------------------------------------------------------

Build time:   2014-07-01 07:45:34 UTC
Build number: none
Revision:     b6ead6fa452dfdadec484059191eb641d817226c

Groovy:       2.3.3
Ant:          Apache Ant(TM) version 1.9.3 compiled on December 23 2013
JVM:          1.7.0_60 (Oracle Corporation 24.60-b09)
OS:           Mac OS X 10.9.4 x86_64
```

# 简单使用

Gradle 使用 [约定优于配置](http://zh.wikipedia.org/wiki/%E7%BA%A6%E5%AE%9A%E4%BC%98%E4%BA%8E%E9%85%8D%E7%BD%AE)(Convention over Configuration)的理念。使用与maven兼容的目录结构布局。完全按照约定的目录结构来布置工程文件，会大大简化编译配置文件。

除了常见的src/main/java等目录，默认的 web 应用程序根目录为 src/main/webapp，也就是包含 WEB-INF 目录的上一级目录。如果工程没有完全依照约定布局，可以通过脚本文件指定相应的路径。

Gradle 中有两个最基本的对象：project 和 task。每个 Gradle 的构建由一个 project 对象来表达，它代表着需要被构建的组件或者构建的整个项目。每个 project 对象由一个或者多个 task 对象组成。

Gradle 已经自带了很多 pugins，可以满足大部分的常见构建任务。

Gradle 的默认构建脚本文件为工程根目录下的 build.gradle。

## 创建项目

作为测试，创建一个 test 目录，然后通过下面命令来初始化一个项目：

```bash
$ mkdir test
$ cd test
$ gradle init
:wrapper
:init

BUILD SUCCESSFUL

Total time: 3.058 secs

$ ls
build.gradle    gradle          gradlew         gradlew.bat     settings.gradle
```

可以看到生成了 gradle 的一些配置文件。接下来在 build.gradle 文件中添加下面代码，可以支持生成 jar 包：

```groovy
apply plugin: 'java'
```

这就是你定义一个Java项目所需要做的一切。这就会在你项目里使用Java插件，该插件会给你的项目增加很多任务。

Gradle 期望在 src/main/java 路径下找到你项目的源代码，并且测试在 src/test/java 路径下的代码。同时，在src/main/resources 路径下的文件也会作为资源文件包含在JAR包中，并且 src/test/resources 下的所有文件会包含在 classpath 下以运行测试程序。所有的输出文件都生成在 build 目录下，JAR 包生成在 build/libs 目录下。

运行下面命令即可生成 jar 包：

```
$ gradle jar
```

如果 jar 包中有一个包含 main 方法的主类，想让其打包之后能够运行其 main 方法，则需要添加下面代码：


```groovy
apply plugin: 'java'

jar {
    manifest {
        attributes 'Main-Class': 'com.javachen.gradle.HelloWorld'
    }
}
```

通常，JAR 包需要被发布到某个地方。为了完成这个功能，你需要告诉 Gradle 把 JAR 包发布到哪里。在 Gradle 中，如 JAR 之类的压缩包都被发布到库中。在我们的样例中，我们将会发布到本地仓库。你也可以发布到一个或多个远端地址。

发布 jar 包添加如下配置：

```groovy
uploadArchives {
    repositories {
       flatDir {
           dirs 'repos'
    } }
}
```

此外，你还可以添加下面代码，引入 Eclipse 插件以支持生成 Eclipse 工程：

```groovy
apply plugin: 'eclipse'
```

添加Maven库：

```groovy
repositories {
    mavenCentral()
}
```

如果想添加依赖，也是非常简单，例如添加 spring 依赖：

```groovy
apply plugin: 'java'
dependencies {
    compile 'org.springframework:spring-context:3.2.6.RELEASE'
    testCompile group: 'junit', name: 'junit', version: '4.+'
}
```

gradle 便会自动地到 maven 服务器下载 spring-context-3.2.6.RELEASE.jar，以及它所依赖的 jar 包。

常用的依赖：

- （1）compile：编译生产代码的依赖环境，即src/main/下
- （2）runtime：生产代码运行时的依赖（包含编译生产代码时的依赖）
- （3）testCompile：编译测试代码的依赖环境，即src/test下
- （4）testRuntime：测试代码运行时的依赖（包含编译测试代码时的依赖）

当然，也可以直接依赖本地的 jar 包，例如：

```groovy
apply plugin: 'java'
dependencies {
    compile fileTree(dir: 'libs', include: '*.jar')
}
```

也可以通过 `buildscript{}` 中添加依赖的方式，将相关 jar 包加入到 classpath 中，如：

```groovy
buildscript {  
    repositories {  
        mavenCentral()  
    }  
    dependencies {  
        classpath group: 'commons-codec', name: 'commons-codec', version: '1.2'  
    }  
}  
```

综上，完成的配置如下：

```groovy
apply plugin: 'java'
apply plugin: 'eclipse'

jar {
    manifest {
        attributes 'Main-Class': 'com.javachen.gradle.HelloWorld'
    }
}

repositories {
    mavenLocal()
    mavenCentral()
    mavenRepo urls: "http://repository.sonatype.org/content/groups/forge/"
}

dependencies {
    compile 'org.springframework:spring-context:3.2.6.RELEASE'
    testCompile group: 'junit', name: 'junit', version: '4.+'
    compile fileTree(dir: 'libs', include: '*.jar')
}

buildscript {  
    repositories {  
        mavenLocal()
        mavenCentral()
        mavenRepo urls: "http://repository.sonatype.org/content/groups/forge/"
    }  
    dependencies {  
        classpath group: 'commons-codec', name: 'commons-codec', version: '1.2'  
    }  
}  

uploadArchives {
    repositories {
        flatDir {
            dirs 'repos'
        }
    }
}
```

# 其他使用

## 创建项目目录结构

gradle 不像 maven 那样有固定的项目结构，gradle 原声 API 是不支持的，要想做到这一点，我们可以自定义一个 task。

```groovy
apply plugin: 'idea'
apply plugin: 'java'
apply plugin: 'war'

task createJavaProject << {
  sourceSets*.java.srcDirs*.each { it.mkdirs() }
  sourceSets*.resources.srcDirs*.each { it.mkdirs()}
}

task createWebProject(dependsOn: 'createJavaProject') << {
  def webAppDir = file("$webAppDirName")
  webAppDir.mkdirs()
}
```

然后运行下面命令：

```bash
$ gradle createJavaProject
```

另外，还可以使用 [gradle templates](http://tellurianring.com/wiki/gradle/templates) 创建项目目录结构，这里不做研究。

更加标准的方法是使用 gradle 自带的插件创建项目目录结构，例如创建 java 项目结构：

```bash
$ gradle init --type java-library
```

这时候的目录结果如下：

```bash
$ tree -L 4
.
├── build.gradle
├── gradle
│   └── wrapper
│       ├── gradle-wrapper.jar
│       └── gradle-wrapper.properties
├── gradlew
├── gradlew.bat
├── settings.gradle
└── src
    ├── main
    │   └── java
    │       └── Library.java
    └── test
        └── java
            └── LibraryTest.java

7 directories, 8 files
```

如果想要导入到 idea 中，先执行下面命令：

```bash
$ gradle idea
```

这时候的 build.gradle 如下：

```groovy
apply plugin: 'idea'
apply plugin: 'java'
apply plugin: 'war'

task createJavaProject << {
      sourceSets*.java.srcDirs*.each { it.mkdirs() }
        sourceSets*.resources.srcDirs*.each { it.mkdirs()}
}

task createWebProject(dependsOn: 'createJavaProject') << {
      def webAppDir = file("$webAppDirName")
        webAppDir.mkdirs()
}
```

## 将Java项目从maven迁移到gradle

如何将一个 java 项目从maven迁移到 gradle 呢？gradle 集成了一个很方便的插件：`Build Init Plugin`，使用这个插件可以很方便地创建一个新的 gradle 项目，或者将其它类型的项目转换为 gradle 项目。

要将 maven 项目转换为 gradle 项目，只需要在项目的 pom 文件所在的目录下执行以下命令：

```bash
$ gradle init --type pom
```

上面的命令会根据 pom 文件自动生成 gradle 项目所需的文件和配置，然后以 gradle 项目重新导入即可。


# 参考

- [1] [Gradle安装与简单使用](http://openwares.net/java/gradle_intro.html)
- [2] [gradle太好用了](http://sulong.me/2011/01/26/greate_gradle)
