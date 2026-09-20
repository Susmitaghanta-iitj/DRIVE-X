from model_desc import Layer, AF_RELU, AF_SIG

def _attr_int(node,name,default):
    for a in node.attribute:
        if a.name==name:
            if len(a.ints): return list(a.ints)
            return int(a.i)
    return default

def lower_onnx(path):
    try:
        import onnx
        from onnx import shape_inference
    except Exception as e:
        raise RuntimeError("Install onnx to use the importer.") from e
    model=shape_inference.infer_shapes(onnx.load(path)); layers=[]
    for idx,node in enumerate(model.graph.node):
        name=node.name or f"{node.op_type}_{idx}"; op=node.op_type
        if op=="Conv":
            ks=_attr_int(node,"kernel_shape",[1,1]); st=_attr_int(node,"strides",[1,1]); pads=_attr_int(node,"pads",[0,0,0,0]); layers.append(Layer(name=name,op="conv",k=int(ks[0]),stride=int(st[0]),pad=int(pads[0])))
        elif op=="Add": layers.append(Layer(name=name,op="add"))
        elif op=="Concat": layers.append(Layer(name=name,op="concat"))
        elif op=="Resize": layers.append(Layer(name=name,op="upsample"))
        elif op=="Sigmoid": layers.append(Layer(name=name,op="activation",af=AF_SIG))
        elif op=="Relu": layers.append(Layer(name=name,op="activation",af=AF_RELU))
        else: layers.append(Layer(name=name,op="unsupported"))
    return layers
