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

abstract type AbstractDenseNet <: AbstractNet end


abstract type AbstractContinuousDenseNet <: AbstractDenseNet end
abstract type AbstractContinuousDenseNetSimple <: AbstractDenseNet end
abstract type AbstractContinuousDenseNetStochastic <: AbstractDenseNet end
abstract type AbstractContinuousDenseNetMassAction <: AbstractDenseNet end
abstract type AbstractDiscreteDenseNet <: AbstractDenseNet end
abstract type AbstractDiscreteEnergyDenseNet <: AbstractDenseNet end


abstract type AbstractSparseNet <: AbstractNet end
abstract type AbstractDiscreteSparseNet <: AbstractSparseNet end
abstract type AbstractDiscreteEnergySparseNet <: AbstractDiscreteSparseNet end


########################################################################################################################
## Abstract rewriting-related types
abstract type AbstractRule end
abstract type AbstractDenseRule <: AbstractRule end 
abstract type AbstractSparseRule <: AbstractRule end

abstract type AbstractNetRewritingSystem end 
abstract type AbstractSparseNetRewritingSystem end 
abstract type AbstractDenseNetRewritingSystem end 

