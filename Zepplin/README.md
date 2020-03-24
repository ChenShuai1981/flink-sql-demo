# Flink support with Zepplin 0.90 

This is a Dockerfile for Zeppline v0.90 with support for Flink.

Based on 
- https://github.com/apache/zeppelin/blob/branch-0.9/scripts/docker/zeppelin/bin/Dockerfile
- https://www.bilibili.com/video/av91740063/?spm_id_from=333.788.videocard.2


## Update

- March 23, 2020

The `0.9.0-SNAPSHOT` version is not released on http://archive.apache.org/dist/zeppelin/zeppelin-0.9.0-SNAPSHOT/zeppelin-0.9.0-SNAPSHOT-bin-all.tgz.

Duh.

You also get the following trying to install `IRKernel`. It looks like it can't find the `python` installation, because we just installed `jupyter`.

```
Error in IRkernel::installspec() :
  jupyter-client has to be installed but “jupyter kernelspec --version” exited with code 127.
```  