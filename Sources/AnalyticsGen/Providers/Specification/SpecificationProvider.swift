import Foundation
import PromiseKit

protocol SpecificationProvider {

    // MARK: - Instance Methods

    func fetchSpecification(from specificationPath: String) -> Promise<Specification>
}
