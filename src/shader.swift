public let shader =
  """
  #include <metal_stdlib>
  using namespace metal;

  struct Cpu2Vertex {
      float3 position;
      float4 color;
  };

  struct Vertex2Fragment {
      float4 position [[ position ]];
      float4 color;
  };

  vertex Vertex2Fragment vertex_function(const device Cpu2Vertex *vertices [[ buffer(0) ]],
                                         uint vertexID [[ vertex_id ]]) {
      Vertex2Fragment r;
      r.position = float4(vertices[vertexID].position, 1);
      r.color = vertices[vertexID].color;
      return r;
  }

  fragment float4 fragment_function(Vertex2Fragment v [[ stage_in ]]) {
      return v.color;
  }
  """
