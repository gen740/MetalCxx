import MetalKit
import SwiftUI

class MetalViewCoordinator: NSObject, MTKViewDelegate {
  var view: MTKView
  var device: MTLDevice!
  var library: MTLLibrary!
  var commandQueue: MTLCommandQueue!
  var renderPipelineState: MTLRenderPipelineState!
  var vertexBuffer: MTLBuffer!

  func makeCommandBuffer() -> MTLCommandBuffer {
    commandQueue.makeCommandBuffer()!
  }

  struct Vertex {
    var position: simd_float3
    var color: simd_float4
  }

  var vertices: [Vertex] = [
    Vertex(position: simd_float3(0, 1, 0), color: simd_float4(1, 0, 0, 1)),
    Vertex(position: simd_float3(-1, -1, 0), color: simd_float4(0, 1, 0, 1)),
    Vertex(position: simd_float3(1, -1, 0), color: simd_float4(0, 0, 1, 1)),
  ]

  init(_ view: MTKView) {
    self.view = view
    self.device = view.device

    do {
      library = try device.makeLibrary(source: shader, options: nil)
    } catch {
      fatalError()
    }

    commandQueue = device.makeCommandQueue()

    let desc = MTLRenderPipelineDescriptor()
    desc.colorAttachments[0].pixelFormat = .bgra8Unorm
    desc.vertexFunction = library.makeFunction(name: "vertex_function")
    desc.fragmentFunction = library.makeFunction(name: "fragment_function")
    renderPipelineState = try! device.makeRenderPipelineState(descriptor: desc)
    vertexBuffer = device.makeBuffer(
      bytes: vertices, length: MemoryLayout<Vertex>.stride * vertices.count, options: [])

    super.init()
  }

  func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    guard view.frame.size != size else { return }
    view.drawableSize = view.frame.size
  }

  func draw(in view: MTKView) {
    let cmdbuf = commandQueue.makeCommandBuffer()!
    let cmdenc = cmdbuf.makeRenderCommandEncoder(descriptor: view.currentRenderPassDescriptor!)!
    cmdenc.setRenderPipelineState(renderPipelineState)
    cmdenc.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
    cmdenc.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)
    cmdenc.endEncoding()
    cmdbuf.present(view.currentDrawable!)
    cmdbuf.commit()
  }
}

struct MetalView: NSViewRepresentable {
  typealias NSViewType = MTKView
  typealias Coordinator = MetalViewCoordinator

  func makeCoordinator() -> MetalViewCoordinator {
    let view = MTKView()
    view.device = view.preferredDevice
    return MetalViewCoordinator(view)
  }

  func makeNSView(context: Context) -> MTKView {
    let view = context.coordinator.view
    view.delegate = context.coordinator
    view.enableSetNeedsDisplay = true
    return view
  }

  func updateNSView(_ view: MTKView, context: Context) {}

  static func dismantleNSView(_ view: MTKView, coordinator: ()) {}
}
