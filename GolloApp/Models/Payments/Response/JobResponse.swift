//
//  JobResponse.swift
//  GolloApp
//
//  Created by Rodrigo Osegueda on 3/1/24.
//

import Foundation

struct JobResponse: Codable {
    let error: String?
    let data: DataJobResponse?
    let message, job_id: String?
}

struct DataJobResponse: Codable {
    let slotId: String?
}
