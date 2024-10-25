import SwiftSyntax
import SwiftParser
import SwiftSyntaxBuilder

func generateAggregateProtocols() -> [CodeBlockItemSyntax] {
    let numericTypable = ProtocolDeclSyntax(
        name: .identifier("PostgresNumericTypable"),
        inheritanceClause: InheritanceClauseSyntax(
            inheritedTypes: InheritedTypeListSyntax {
                InheritedTypeSyntax(
                    type: IdentifierTypeSyntax(
                        name: .identifier("AdditiveArithmetic")
                    )
                )
            }
        ),
        memberBlock: MemberBlockSyntax(
            members: MemberBlockItemListSyntax {
                MemberBlockItemSyntax(
                    decl: InitializerDeclSyntax(
                        signature: FunctionSignatureSyntax(
                            parameterClause: FunctionParameterClauseSyntax(
                                parameters: FunctionParameterListSyntax { }
                            )
                        )
                    )
                )
            }
        )
    )
    
    let typable = ProtocolDeclSyntax(
        name: .identifier("PostgresTypable"),
        inheritanceClause: InheritanceClauseSyntax(
            inheritedTypes: InheritedTypeListSyntax {
                InheritedTypeSyntax(
                    type: IdentifierTypeSyntax(
                        name: .identifier("Comparable")
                    )
                )
            }
        ),
        memberBlock: MemberBlockSyntax(
            members: MemberBlockItemListSyntax {
                MemberBlockItemSyntax(
                    decl: InitializerDeclSyntax(
                        signature: FunctionSignatureSyntax(
                            parameterClause: FunctionParameterClauseSyntax(
                                parameters: FunctionParameterListSyntax { }
                            )
                        )
                    )
                )
            }
        )
    )
    
    let numericTypableItem = CodeBlockItemSyntax(
        item: CodeBlockItemSyntax.Item(numericTypable)
    )
    
    let typableItem = CodeBlockItemSyntax(
        item: CodeBlockItemSyntax.Item(typable)
    )
    
    return [numericTypableItem, typableItem]
}

func generateAggregateExtensions() -> [CodeBlockItemSyntax] {
    let intExt = ExtensionDeclSyntax(
        extendedType: IdentifierTypeSyntax(name: .identifier("Int")),
        inheritanceClause: InheritanceClauseSyntax(
            inheritedTypes: InheritedTypeListSyntax {
                InheritedTypeSyntax(
                    type: IdentifierTypeSyntax(
                        name: .identifier("PostgresTypable")))
                
                InheritedTypeSyntax(
                    type: IdentifierTypeSyntax(
                        name: .identifier("PostgresNumericTypable")))
            }
        ),
        memberBlock: MemberBlockSyntax(
            members: MemberBlockItemListSyntax { }
        )
    )
    
    let doubleExt = ExtensionDeclSyntax(
        extendedType: IdentifierTypeSyntax(name: .identifier("Double")),
        inheritanceClause: InheritanceClauseSyntax(
            inheritedTypes: InheritedTypeListSyntax {
                InheritedTypeSyntax(
                    type: IdentifierTypeSyntax(
                        name: .identifier("PostgresTypable")))
                
                InheritedTypeSyntax(
                    type: IdentifierTypeSyntax(
                        name: .identifier("PostgresNumericTypable")))
            }
        ),
        memberBlock: MemberBlockSyntax(
            members: MemberBlockItemListSyntax { }
        )
    )
    
    let stringExt = ExtensionDeclSyntax(
        extendedType: IdentifierTypeSyntax(name: .identifier("String")),
        inheritanceClause: InheritanceClauseSyntax(
            inheritedTypes: InheritedTypeListSyntax {
                InheritedTypeSyntax(
                    type: IdentifierTypeSyntax(
                        name: .identifier("PostgresTypable")))
            }
        ),
        memberBlock: MemberBlockSyntax(
            members: MemberBlockItemListSyntax { }
        )
    )
    
    let dateExt = ExtensionDeclSyntax(
        extendedType: IdentifierTypeSyntax(name: .identifier("Date")),
        inheritanceClause: InheritanceClauseSyntax(
            inheritedTypes: InheritedTypeListSyntax {
                InheritedTypeSyntax(
                    type: IdentifierTypeSyntax(
                        name: .identifier("PostgresTypable")))
            }
        ),
        memberBlock: MemberBlockSyntax(
            members: MemberBlockItemListSyntax { }
        )
    )
    
    let intItem = CodeBlockItemSyntax(
        item: CodeBlockItemSyntax.Item(intExt)
    )
    
    let doubleItem = CodeBlockItemSyntax(
        item: CodeBlockItemSyntax.Item(doubleExt)
    )
    
    let stringItem = CodeBlockItemSyntax(
        item: CodeBlockItemSyntax.Item(stringExt)
    )
    
    let dateItem = CodeBlockItemSyntax(
        item: CodeBlockItemSyntax.Item(dateExt)
    )
    
    return [intItem, doubleItem, stringItem, dateItem]
}

/**
 Generates the equivalent `EnumDeclSyntax` representing a Projected Value
 
 The equivalent code:
 ```swift
 enum ProjectedValue {
     case attribute(name: String)
     case aggregate(func: Aggregate, name: String)
 }
 ```
 */
func generateProjectedValueEnum() -> EnumDeclSyntax {
    // enum ProjectedValue
    let enumDecl = EnumDeclSyntax(
        name: .identifier("ProjectedValue"),
        memberBlock: MemberBlockSyntax(
            members: MemberBlockItemListSyntax {
                // case attribute(name: String)
                MemberBlockItemSyntax(
                    decl: EnumCaseDeclSyntax(
                        elements: EnumCaseElementListSyntax {
                            EnumCaseElementSyntax(
                                name: .identifier("attribute"),
                                parameterClause:
                                    EnumCaseParameterClauseSyntax(
                                        parameters: [
                                            EnumCaseParameterSyntax(
                                                firstName: .identifier("name"),
                                                type: IdentifierTypeSyntax(name: .identifier("String")))
                                        ]
                                    )
                            )
                        }
                    )
                )
                
                // case aggregate(func: Aggregate, name: String)
                MemberBlockItemSyntax(
                    decl: EnumCaseDeclSyntax(
                        elements: EnumCaseElementListSyntax {
                            EnumCaseElementSyntax(
                                name: .identifier("aggregate"),
                                parameterClause:
                                    EnumCaseParameterClauseSyntax(parameters: [
                                            EnumCaseParameterSyntax(
                                                firstName: .identifier("func"),
                                                type: IdentifierTypeSyntax(name: .identifier("Aggregate")),
                                                trailingComma: .commaToken()
                                            ),
                                            
                                            EnumCaseParameterSyntax(
                                                firstName: .identifier("name"),
                                                type: IdentifierTypeSyntax(name: .identifier("String"))
                                            )
                                        ])
                            )
                        }
                    )
                )
            }
        )
    )
    
    return enumDecl
}

/**
 Generates the equivalent `EnumDeclSyntax` for the an enum for predicate operators
 
 The equivalent code:
 ```swift
 enum Operator {
     case and
     case or
 }
 ```
 */
func generateOperatorEnum() -> EnumDeclSyntax {
    // enum Operator
    let enumDecl = EnumDeclSyntax(
        name: .identifier("Operator"),
        memberBlock: MemberBlockSyntax(
            members: MemberBlockItemListSyntax {
                // case and
                MemberBlockItemSyntax(
                    decl: EnumCaseDeclSyntax(
                        elements: EnumCaseElementListSyntax {
                            EnumCaseElementSyntax(name: .identifier("and"))
                        }
                    )
                )
                
                // case or
                MemberBlockItemSyntax(
                    decl: EnumCaseDeclSyntax(
                        elements: EnumCaseElementListSyntax {
                            EnumCaseElementSyntax(name: .identifier("or"))
                        }
                    )
                )
            }
        )
    )
    
    return enumDecl
}

/**
 Generates the equivalent `StructDeclSyntax` for the a structure for Predicates
 
 The equivalent code:
 ```swift
 struct Predicate {
     let value1: String
     let `operator`: Operator
     let value2: String
 }
 ```
 */
func generatePredicateStruct() -> StructDeclSyntax {
    // struct Predicate
    let structDecl = StructDeclSyntax(
        name: .identifier("Predicate"),
        memberBlock: MemberBlockSyntax(
            members: MemberBlockItemListSyntax {
                // let value1: String
                MemberBlockItemListSyntax.Element(
                    decl: VariableDeclSyntax(
                        bindingSpecifier: .keyword(.let),
                        bindings: PatternBindingListSyntax {
                            PatternBindingSyntax(
                                pattern: IdentifierPatternSyntax(identifier: .identifier("value1")),
                                typeAnnotation: TypeAnnotationSyntax(type: IdentifierTypeSyntax(name: .identifier("String")))
                            )
                        }
                    )
                )
                
                // let `operator`: Operator
                MemberBlockItemListSyntax.Element(
                    decl: VariableDeclSyntax(
                        bindingSpecifier: .keyword(.let),
                        bindings: PatternBindingListSyntax {
                            PatternBindingSyntax(
                                pattern: IdentifierPatternSyntax(identifier: .identifier("`operator`")),
                                typeAnnotation: TypeAnnotationSyntax(type: IdentifierTypeSyntax(name: .identifier("Operator")))
                            )
                        }
                    )
                )
                
                // let value2: String
                MemberBlockItemListSyntax.Element(
                    decl: VariableDeclSyntax(
                        bindingSpecifier: .keyword(.let),
                        bindings: PatternBindingListSyntax {
                            PatternBindingSyntax(
                                pattern: IdentifierPatternSyntax(identifier: .identifier("value2")),
                                typeAnnotation: TypeAnnotationSyntax(type: IdentifierTypeSyntax(name: .identifier("String")))
                            )
                        }
                    )
                )
            }
        )
    )
    
    return structDecl
}

/**
 Generates the equivalent `StructDeclSyntax` that represents the Phi Operator
 
 The equivalent structure is as follows:
 ```swift
 struct Phi {
     let projectedValues: [ProjectedValue]
     let numOfGroupingVars: Int
     let groupByAttributes: [String]
     let aggregates: [Aggregate]
     let groupingVarPredicates: [Predicate]
     let havingPredicates: [Predicate]
 }
 ```
 */
func generatePhiStruct() -> StructDeclSyntax {
    // struct Phi
    let structDecl = StructDeclSyntax(
        name: .identifier("Phi"),
        memberBlock: MemberBlockSyntax(
            members: MemberBlockItemListSyntax {
                // let projectedValues: [ProjectedValue]
                MemberBlockItemListSyntax.Element(
                    decl: VariableDeclSyntax(
                        bindingSpecifier: .keyword(.let),
                        bindings: PatternBindingListSyntax {
                            PatternBindingSyntax(
                                pattern: IdentifierPatternSyntax(identifier: .identifier("projectedValues")),
                                typeAnnotation: TypeAnnotationSyntax(
                                    type: ArrayTypeSyntax(
                                        element: IdentifierTypeSyntax(
                                            name: .identifier("String")
                                        )
                                    )
                                )
                            )
                        }
                    )
                )
                
                // let numOfGroupingVars: Int
                MemberBlockItemListSyntax.Element(
                    decl: VariableDeclSyntax(
                        bindingSpecifier: .keyword(.let),
                        bindings: PatternBindingListSyntax {
                            PatternBindingSyntax(
                                pattern: IdentifierPatternSyntax(identifier: .identifier("numOfGroupingVars")),
                                typeAnnotation: TypeAnnotationSyntax(type: IdentifierTypeSyntax(name: .identifier("Int")))
                            )
                        }
                    )
                )
                
                // let groupByAttributes: [String]
                MemberBlockItemListSyntax.Element(
                    decl: VariableDeclSyntax(
                        bindingSpecifier: .keyword(.let),
                        bindings: PatternBindingListSyntax {
                            PatternBindingSyntax(
                                pattern: IdentifierPatternSyntax(identifier: .identifier("groupByAttributes")),
                                typeAnnotation: TypeAnnotationSyntax(
                                    type: ArrayTypeSyntax(
                                        element: IdentifierTypeSyntax(
                                            name: .identifier("String")
                                        )
                                    )
                                )
                            )
                        }
                    )
                )
                
                // let aggregates: [Aggregate]
                MemberBlockItemListSyntax.Element(
                    decl: VariableDeclSyntax(
                        bindingSpecifier: .keyword(.let),
                        bindings: PatternBindingListSyntax {
                            PatternBindingSyntax(
                                pattern: IdentifierPatternSyntax(identifier: .identifier("aggregates")),
                                typeAnnotation: TypeAnnotationSyntax(
                                    type: ArrayTypeSyntax(
                                        element: IdentifierTypeSyntax(
                                            name: .identifier("Aggregate")
                                        )
                                    )
                                )
                            )
                        }
                    )
                )
                
                // let groupingVarPredicates: [Predicate]
                MemberBlockItemListSyntax.Element(
                    decl: VariableDeclSyntax(
                        bindingSpecifier: .keyword(.let),
                        bindings: PatternBindingListSyntax {
                            PatternBindingSyntax(
                                pattern: IdentifierPatternSyntax(identifier: .identifier("groupingVarPredicates")),
                                typeAnnotation: TypeAnnotationSyntax(
                                    type: ArrayTypeSyntax(
                                        element: IdentifierTypeSyntax(
                                            name: .identifier("Predicate")
                                        )
                                    )
                                )
                            )
                        }
                    )
                )
                
                // let havingPredicates: [Predicate]
                MemberBlockItemListSyntax.Element(
                    decl: VariableDeclSyntax(
                        bindingSpecifier: .keyword(.let),
                        bindings: PatternBindingListSyntax {
                            PatternBindingSyntax(
                                pattern: IdentifierPatternSyntax(identifier: .identifier("havingPredicates")),
                                typeAnnotation: TypeAnnotationSyntax(
                                    type: ArrayTypeSyntax(
                                        element: IdentifierTypeSyntax(
                                            name: .identifier("Predicate")
                                        )
                                    )
                                )
                            )
                        }
                    )
                )
            }
        )
    )
    
    return structDecl
}

//func generateOutputCode() {
//    let aggregateEnum = generateAggregateEnum()
//    let projectedValuesEnum = generateProjectedValueEnum()
//    let operatorEnum = generateOperatorEnum()
//    let predicateStruct = generatePredicateStruct()
//    let phiStruct = generatePhiStruct()
//    
//    let syntax = SourceFileSyntax(
//        statements: CodeBlockItemListSyntax {
//            CodeBlockItemSyntax(item: CodeBlockItemSyntax.Item(aggregateEnum))
//            CodeBlockItemSyntax(item: CodeBlockItemSyntax.Item(projectedValuesEnum))
//            CodeBlockItemSyntax(item: CodeBlockItemSyntax.Item(operatorEnum))
//            CodeBlockItemSyntax(item: CodeBlockItemSyntax.Item(predicateStruct))
//            CodeBlockItemSyntax(item: CodeBlockItemSyntax.Item(phiStruct))
//        }
//    )
//    
//    let description = syntax.formatted().description
//
//    print(description)
//}
