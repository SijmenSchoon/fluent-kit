import NIO

extension Database {
    public func schema(_ schema: String) -> SchemaBuilder {
        return .init(database: self, schema: schema)
    }
}

public final class SchemaBuilder {
    let database: Database
    public var schema: DatabaseSchema
    
    init(database: Database, schema: String) {
        self.database = database
        self.schema = .init(schema: schema)
    }

    public func field(
        _ name: String,
        _ dataType: DatabaseSchema.DataType,
        _ constraints: DatabaseSchema.FieldConstraint...
    ) -> Self {
        return self.field(.definition(
            name: .string(name),
            dataType: dataType,
            constraints: constraints
        ))
    }
    
    public func field(_ field: DatabaseSchema.FieldDefinition) -> Self {
        self.schema.createFields.append(field)
        return self
    }
    
    public func unique(on fields: String...) -> Self {
        self.schema.constraints.append(.unique(
            fields: fields.map { .string($0) }
        ))
        return self
    }
    
    public func deleteField(_ name: String) -> Self {
        return self.deleteField(.string(name))
    }
    
    public func deleteField(_ name: DatabaseSchema.FieldName) -> Self {
        self.schema.deleteFields.append(name)
        return self
    }
    
    public func delete() -> EventLoopFuture<Void> {
        self.schema.action = .delete
        return self.database.driver.execute(schema: self.schema, database: self.database)
    }
    
    public func update() -> EventLoopFuture<Void> {
        self.schema.action = .update
        return self.database.driver.execute(schema: self.schema, database: self.database)
    }
    
    public func create() -> EventLoopFuture<Void> {
        self.schema.action = .create
        return self.database.driver.execute(schema: self.schema, database: self.database)
    }
}
