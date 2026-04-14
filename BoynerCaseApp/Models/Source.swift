//
//  Source.swift
//  BoynerCaseApp
//
//  Created by F E on 14.04.2026.
//

import Foundation

// MARK: - Sources API Response
struct SourcesResponse: Codable {
    let status: String
    let sources: [Source]
}

// MARK: - Source Model
struct Source: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let description: String
    let url: String
    let category: String
    let language: String
    let country: String
}
