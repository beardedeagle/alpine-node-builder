# Docker + Alpine + Node = Love

This Dockerfile provides a good base build image to use in multistage builds for Node apps. It comes with the latest version of Alpine, Node and NPM. It is intended for use in creating release images with or for your application and allows you to avoid cross-compiling releases. The exception of course is if your app has dependencies which require a native compilation toolchain, but that is left as an exercise let to the user.

No effort has been made to make this image suitable to run in unprivileged environments. The repository owner is not responsible for any loses that result from improper usage or security practices, as it is expected that the user of this image will implement proper security practices themselves.

## Software/Language Versions

```shell
Alpine 3.8
Nodejs 10.12.0
NPM 6.4.1
```

## Usage

To boot straight to a node prompt in the image:

```shell
$ docker run --rm -i -t beardedeagle/alpine-node-builder node
>
```
