//
//  FetchAnisetteDataOperation.swift
//  AltStore
//
//  Created by Riley Testut on 1/7/20.
//  Copyright © 2020 Riley Testut. All rights reserved.
//

import Foundation

import AltSign
import AltKit

import Roxas

@objc(FetchAnisetteDataOperation)
class FetchAnisetteDataOperation: ResultOperation<ALTAnisetteData>
{
    let group: OperationGroup
    
    init(group: OperationGroup)
    {
        self.group = group
        
        super.init()
    }
    
    override func main()
    {
        super.main()
        
        if let error = self.group.error
        {
            self.finish(.failure(error))
            return
        }
        
        guard let server = self.group.server else { return self.finish(.failure(OperationError.invalidParameters)) }
        
        ServerManager.shared.connect(to: server) { (result) in
            switch result
            {
            case .failure(let error):
                self.finish(.failure(error))
            case .success(let connection):
                print("Sending anisette data request...")
                
                let request = AnisetteDataRequest()
                connection.send(request) { (result) in
                    print("Sent anisette data request!")
                    
                    switch result
                    {
                    case .failure(let error): self.finish(.failure(error))
                    case .success:
                        print("Waiting for anisette data...")
                        connection.receiveResponse() { (result) in
                            print("Receiving anisette data:", result)
                            
                            switch result
                            {
                            case .failure(let error): self.finish(.failure(error))
                            case .success(.error(let response)): self.finish(.failure(response.error))
                            case .success(.anisetteData(let response)): self.finish(.success(response.anisetteData))
                            case .success: self.finish(.failure(ALTServerError(.unknownRequest)))
                            }
                        }
                    }
                }
            }
        }
    }
}
