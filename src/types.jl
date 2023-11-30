########################################################################################################################
## Abstract utility types
abstract type AbstractSymmetry end

########################################################################################################################
## Abstract token types
abstract type AbstractToken end

abstract type AbstractRuleToken <: AbstractToken end

abstract type AbstractEnergyToken <: AbstractToken end

abstract type AbstractEnergyRuleToken <: AbstractRuleToken end 

########################################################################################################################
## Abstract net types

abstract type AbstractNet end

abstract type AbstractEnergyNet <: AbstractNet end 

abstract type AbstractDenseEnergyNet <: AbstractEnergyNet end 

abstract type AbstractSparseEnergyNet <: AbstractEnergyNet end 

abstract type AbstractDiscreteDenseEnergyNet <: AbstractDenseEnergyNet end

abstract type AbstractDiscreteSparseEnergyNet <: AbstractSparseEnergyNet end

abstract type AbstractBasicNet <: AbstractNet end 

abstract type AbstractDenseBasicNet <: AbstractBasicNet end 

abstract type AbstractSparseBasicNet <: AbstractBasicNet end 

abstract type AbstractDiscreteDenseBasicNet <: AbstractDenseBasicNet end

abstract type AbstractDiscreteSparseBasicNet <: AbstractSparseBasicNet end


########################################################################################################################
## Abstract rewriting rule types
abstract type AbstractRule end

abstract type AbstractBasicRule <: AbstractRule end 

abstract type AbstractDenseBasicRule <: AbstractBasicRule end 

abstract type AbstractSparseBasicRule <: AbstractBasicRule end 

abstract type AbstractDiscreteDenseBasicRule <: AbstractDenseBasicRule end 

abstract type AbstractDiscreteSparseBasicRule <: AbstractSparseBasicRule end


abstract type AbstractEnergyRule <: AbstractRule end

abstract type AbstractDenseEnergyRule <: AbstractEnergyRule end 

abstract type AbstractSparseEnergyRule <: AbstractEnergyRule end 

abstract type AbstractDiscreteDenseEnergyRule <: AbstractDenseEnergyRule end 

abstract type AbstractDiscreteSparseEnergyRule <: AbstractSparseEnergyRule end


########################################################################################################################
## Abstract rewriting system types
abstract type AbstractNetRewritingSystem end 

abstract type AbstractBasicNetRewritingSystem <: AbstractNetRewritingSystem end

abstract type AbstractSparseBasicNetRewritingSystem <: AbstractBasicNetRewritingSystem end 

abstract type AbstractDenseBasicNetRewritingSystem <: AbstractBasicNetRewritingSystem end 

abstract type AbstractDiscreteSparseBasicNetRewritingSystem<: AbstractSparseBasicNetRewritingSystem end 

abstract type AbstractDiscreteDenseBasicNetRewritingSystem <: AbstractDenseBasicNetRewritingSystem end


abstract type AbstractEnergyNetRewritingSystem <: AbstractNetRewritingSystem end

abstract type AbstractSparseEnergyNetRewritingSystem <: AbstractEnergyNetRewritingSystem end 

abstract type AbstractDenseEnergyNetRewritingSystem <: AbstractEnergyNetRewritingSystem end 

abstract type AbstractDiscreteSparseEnergyNetRewritingSystem<: AbstractSparseBEnergyetRewritingSystem end 

abstract type AbstractDiscreteDenseEnergyNetRewritingSystem <: AbstractDenseEnergyNetRewritingSystem end