# dhall-to-k8s

Helper Types and functions for generating all the k8s objects for a namespace.

## Try it with the example

`rm -fr /tmp/dir.yml /tmp/out; mkdir /tmp/out && IMAGE='"registy:5000/test/myimage:2.1"' dhall-to-yaml --file ./example/foo/stable-int/namespaceDirectory.dhall > /tmp/dir.yml && ./gen-dir.sh /tmp/dir.yml /tmp/out && ls -l /tmp/out`