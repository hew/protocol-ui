import assert from 'node:assert/strict'
import * as MetadataParser from '../../src/analysis/MetadataParser.res.mjs'
import * as Scorer from '../../src/analysis/ComplexityScorer.res.mjs'

// Convenience: clone mock metadata and override selected keys
function makeMeta (overrides = {}) {
  const base = MetadataParser.generateMockMetadata()
  return { ...base, ...overrides }
}

// ─────────────────────────────────────────────────────────────
// 1. Minimal organisation ⇒ should be "Simple" difficulty  
// ─────────────────────────────────────────────────────────────
{
  const meta = makeMeta({
    customObjects: [],
    apexClasses: [],
    workflows: [],
    integrations: [],
    edition: 'Developer', // Use Developer edition to minimize base complexity
    dataVolume: { totalRecords: 0, storageUsedMB: 0, fileStorageUsedMB: 0, apiCallsPerDay: 0, totalUsers: 1 }
  })

  const result = Scorer.calculateComplexity(meta)
  assert.equal(result.migrationDifficulty, 'Simple')
  assert.ok(result.totalScore <= 50, `Expected low score, got ${result.totalScore}`)
}

// ─────────────────────────────────────────────────────────────
// 2. Boundary: score just over 50 ⇒ "Moderate" difficulty
//    We fabricate 26 custom objects (26*2 = 52 points)
// ─────────────────────────────────────────────────────────────
{
  const emptyCO = () => ({
    objectName: 'EdgeCase',
    objectLabel: 'EdgeCase',
    fields: [],
    recordTypes: [],
    validationRules: 0,
    triggers: 0
  })

  const meta = makeMeta({
    customObjects: Array.from({ length: 26 }, emptyCO),
    apexClasses: [],
    workflows: [],
    integrations: [],
    dataVolume: { totalRecords: 0, storageUsedMB: 0, fileStorageUsedMB: 0, apiCallsPerDay: 0 }
  })

  const { totalScore, migrationDifficulty } = Scorer.calculateComplexity(meta)
  assert.equal(totalScore, 52)
  assert.equal(migrationDifficulty, 'Moderate')
}

// ─────────────────────────────────────────────────────────────
// 3. Version-age clamp: ensure no negative score
// ─────────────────────────────────────────────────────────────
{
  const meta = makeMeta({
    version: MetadataParser.Winter25, // latest
    migrationMotivation: 'High'       // would subtract 10 without clamp
  })

  const score = Scorer.scoreVersionAge(meta, Scorer.defaultWeights)
  assert.ok(score >= 0, `Version age score should be non-negative, got ${score}`)
}

console.log('✅  All ComplexityScorer edge-case tests passed!') 