# Flink support with Zepplin 0.90 

This is a Dockerfile for Zeppline v0.90 with support for Flink.

Based on 
- https://github.com/apache/zeppelin/blob/branch-0.9/scripts/docker/zeppelin/bin/Dockerfile
- https://www.bilibili.com/video/av91740063/?spm_id_from=333.788.videocard.2


## Update

- Apr 6, 2020

[Zeppelin 0.9preview1](https://github.com/apache/zeppelin/tree/c46c3d7efc27477ccde53893b0ef0c394f6fe44d/scripts/docker/zeppelin/bin) was released as a Dockerfile. 

Updated the [Dockerfile](Dockerfile) to the `0.9preview1` release; remember to copy the [log4j.properties](log4j.properties) file as well. `docker build -t zeppelin09p .` works well. `docker run -p 8080:8080 -it zeppelin09p` also works at http://localhost:8080. 

Flink interpreter can't find `FLINK_HOME`, though, meaning Flink standalone is not installed by default. Will need to configure -- thinking to set up as a docker-compose set up. 

Resources: Jeff Zhang published a series of Media blogs:

- https://medium.com/@zjffdu/flink-on-zeppelin-part-1-get-started-2591aaa6aa47
- https://medium.com/@zjffdu/flink-on-zeppelin-part-2-batch-711731df5ad9
- https://medium.com/@zjffdu/flink-on-zeppelin-part-3-streaming-5fca1e16754
- https://medium.com/@zjffdu/flink-on-zeppelin-part-4-advanced-usage-998b74908cd9

- March 23, 2020

The `0.9.0-SNAPSHOT` version is not released on http://archive.apache.org/dist/zeppelin/zeppelin-0.9.0-SNAPSHOT/zeppelin-0.9.0-SNAPSHOT-bin-all.tgz.

Duh.

You also get the following trying to install `IRKernel`. It looks like it can't find the `python` installation, because we just installed `jupyter`.

```
Error in IRkernel::installspec() :
  jupyter-client has to be installed but “jupyter kernelspec --version” exited with code 127.
```  