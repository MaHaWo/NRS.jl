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

abstract type AbstractDiscreteNet <: AbstractNet end 

abstract type AbstractContinuousNet <: AbstractNet end 

abstract type  AbstractDenseDiscreteNet <: AbstractDiscreteNet end 

abstract type  AbstractSparseDiscreteNet <: AbstractDiscreteNet  end 


abstract type  AbstractBasicDenseDiscreteNet <: AbstractDenseDiscreteNet  end 

abstract type  AbstractBasicSparseDiscreteNet <: AbstractSparseDiscreteNet  end 


abstract type  AbstractEnergyDenseDiscreteNet <: AbstractDenseDiscreteNet  end 

abstract type  AbstractEnergySparseDiscreteNet <: AbstractSparseDiscreteNet  end 


########################################################################################################################
## Abstract rewriting rule types
abstract type AbstractRule end

abstract type AbstractSparseRule <: AbstractRule end 

abstract type AbstractDenseRule <: AbstractRule end 


########################################################################################################################
## Abstract rewriting system types
abstract type AbstractNetRewritingSystem end 

abstract type AbstractDenseNetRewritingSystem <: AbstractNetRewritingSystem end 

abstract type AbstractSparseNetRewritingSystem <: AbstractNetRewritingSystem end 