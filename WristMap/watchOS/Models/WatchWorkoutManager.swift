//
//  WatchWorkoutManager.swift
//  WristMap Watch App
//

import Foundation
import HealthKit

// track user position in the background on apple watches with HealthKit
final class WatchWorkoutManager: NSObject, HKWorkoutSessionDelegate {
    private var healthStore = HKHealthStore()
    private var workout: HKWorkoutSession?
    
    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available")
            return
        }
        let typesToShare: Set<HKSampleType> = [
            HKObjectType.workoutType(),
            HKSeriesType.workoutRoute()
        ]
        
        healthStore.requestAuthorization(
            toShare: typesToShare,
            read: []
        ) { success, error in
            DispatchQueue.main.async {
                if let error {
                    print("HealthKit a  uthorization failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func startWorkoutSession() {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .cycling
        configuration.locationType = .outdoor
        
        do {
            let session = try HKWorkoutSession(
                healthStore: healthStore,
                configuration: configuration
            )
            
            session.delegate = self
            workout = session
            
            session.startActivity(with: Date())
        } catch {
            print("Failed to start session: \(error.localizedDescription)")
        }
    }
    
    func stopWorkoutSession() {
        workout?.end()
        workout = nil
    }
    
    func workoutSession(
        _ workoutSession: HKWorkoutSession,
        didChangeTo toState: HKWorkoutSessionState,
        from fromState: HKWorkoutSessionState,
        date: Date
    ) {
        print("workout session \(fromState) -> \(toState)")
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: any Error) {
        print("Workout session error: \(error.localizedDescription)")
    }
}
