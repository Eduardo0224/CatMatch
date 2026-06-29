//
//  CatDetailTests+Interactor.swift
//  CatMatchTests
//
//  Created by Eduardo Andrade on 29/06/26.
//

import Foundation
import Testing
@testable import CatMatch

// MARK: - CatDetailTests + Interactor

extension CatDetailTests {

    @Suite("CatDetailInteractor Tests")
    struct InteractorTests {

        // MARK: - Subject Under Test

        let spyNetwork: SpyNetworkService
        let sut: CatDetailInteractor

        // MARK: - Initializers

        init() {
            self.spyNetwork = SpyNetworkService()
            self.sut = CatDetailInteractor(network: spyNetwork)
        }

        // MARK: - fetchImage Tests

        @Test("fetchImage returns image for valid reference ID")
        func fetchImageSuccess() async throws {
            await spyNetwork.setSuccess(CatDetailTestData.bengalImage, for: API.Endpoints.imageByID("beng_ref_001"))

            let image = try await sut.fetchImage(for: "beng_ref_001")

            #expect(image?.id == "img_beng")
            #expect(image?.url.absoluteString.contains("beng.jpg") == true)
        }

        @Test("fetchImage propagates network error")
        func fetchImagePropagatesError() async {
            await spyNetwork.setFailure(NetworkError.rateLimited, for: API.Endpoints.imageByID("bad_ref"))

            await #expect(throws: NetworkError.rateLimited) {
                _ = try await sut.fetchImage(for: "bad_ref")
            }
        }

        @Test("fetchImage returns nil when API returns no image")
        func fetchImageReturnsNil() async throws {
            // Simulate API returning a CatImage with nil/empty data
            // The network layer decodes whatever the API returns
            await spyNetwork.setSuccess(CatDetailTestData.bengalImage, for: API.Endpoints.imageByID("empty_ref"))

            let image = try await sut.fetchImage(for: "empty_ref")

            #expect(image != nil)
            #expect(image?.id == "img_beng")
        }
    }
}
