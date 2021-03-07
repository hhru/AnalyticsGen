import Foundation
import PromiseKit
import PathKit
import Yams

final class DefaultSpecificationProvider: SpecificationProvider {

    // MARK: - SpecificationProvider

    func fetchSpecification(from specificationPath: String) -> Promise<Specification> {
        Promise { seal in
            let specificationPath = Path(specificationPath)
            let specificationContent = try specificationPath.read(.utf8)

            if let specification = try Yams.load(yaml: specificationContent) as? Specification {
                seal.fulfill(specification)
            } else {
                seal.reject(
                    SpecificationProviderError(code: .invalidSpecification(path: specificationPath.string))
                )
            }
        }
    }
}
