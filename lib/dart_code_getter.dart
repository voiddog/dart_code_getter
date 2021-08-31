import 'package:vm_service/utils.dart';
import 'package:vm_service/vm_service.dart';
import 'package:vm_service/vm_service_io.dart';

/// 获取源码
/// [vmServiceUri] 虚拟机服务 uri
/// [packageName] 需要获取源码的名称
Stream<Script> fetchSourceCode(String vmServiceUri, String packageName) async* {
  var wsUri =
      convertToWebSocketUrl(serviceProtocolUrl: Uri.parse(vmServiceUri));
  var vmService = await vmServiceConnectUri(wsUri.toString());
  var vm = await vmService.getVM();
  for (var isolateRef in vm.isolates ?? []) {
    final isolate = await vmService.getIsolate(isolateRef.id!);
    for (var libraryRef in isolate.libraries ?? []) {
      if (libraryRef.uri?.contains(packageName) != true) {
        continue;
      }
      // get script
      try {
        final library = (await vmService.getObject(
            isolateRef.id!, libraryRef.id!)) as Library;
        for (var scriptRef in library.scripts ?? []) {
          final script = (await vmService.getObject(
              isolateRef.id!, scriptRef.id!)) as Script;
          yield script;
        }
      } catch (_) {}
    }
  }
}
