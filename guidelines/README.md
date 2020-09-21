# API management guideline
This page provides guidelines to manage API using protocol buffers.

 ## Using Buf
 When working with protobufs, Buf's linter, as described in Ensuring code quality across Protobuf APIs has been agreed as the utility to be used for checking the quality of protobufs.
 
 Use Buf to automate adherence to an agreed, community-tried-and-tested style guide.
 
 Use this linter to check that :
 
 - File names adhere to the naming convention
 
 - Files with package X must be within a directory X relative to root
 
 - Service names end in Service
 
 - Method names are PascalCase
 
 - Field names are lower_snake_case
 
 - Fields and messages have a non-empty comment for documentation.
 
 - Enumerations have a proper zero-value default and enum values are properly named (with prefix)
 
 In addition to the above checks, Buf automates detection of breaking changes (i.e. making new interface incompatible with existing clients) and reduces time required to manage and code review proto files, as part of the code review is automated.
 
 
 ## Using the DEFAULT lint category
 There’s no reason to NOT use the DEFAULT lint category. This is the most “strict” category that encompasses MINIMAL and BASIC categories. A description of the lint categories and styles enforced by the DEFAULT category can be found in the Checkers and Categories section of the Buf online documentation.
 
 In addition, to ensure that all message types and elements are documented, the COMMENTS category must also be included.
 
 In the buf.yaml file, the two categories are enabled like this:
 ```
 lint:
   use:
     - DEFAULT
     - COMMENTS
```

 The DEFAULT category influences the recommended stylistic approach documented below.
 
 
 ## Unique messages for RPC requests and responses
  It’s important to keep in mind that APIs may change over time, and you probably don’t want to couple two separate RPC calls tightly together.
 
 
 ## Exercise caution when creating generic objects
 When creating a generic object, make sure the GRPC framework doesn't already provide something similar.
 
 
 Some common GRPC messages:
 https://github.com/googleapis/googleapis/blob/master/google/rpc/status.proto  
 
 https://github.com/googleapis/googleapis/blob/master/google/rpc/code.proto 
 
 https://github.com/googleapis/googleapis/blob/master/google/rpc/error_details.proto 
 
 
 ## Provision of API documentation
 Always add comments to the Protobuf's objects. The Protobuf API is the contract/documentation between all microservices. 
 
 Comments, enforced by Buf's linter, must contain all information necessary to understand everything about the object.
 
 For guidelines on the format of documentation required, see Phoenix API documentation style guide.
 
 
 ## Protobuf update
 
 Protobuf binary compatibility != application compatibility
 For example, changing a field name will not affect protobuf encoding or compatibility between applications that use proto definitions which differ only by field names. The binary protobuf encoding is based on tag numbers, so that is what you need to preserve, however, the specific language generated code will change and you will not use the same method to access the field.
 
 Also, changing a field name will affect JSON representation if you use that feature.
 
 
 ## Deprecated fields
 As a project evolves, its API changes. Over time, there are certain fields, types, methods or services that we don't want people to use anymore.
 
 Instead of breaking the backward compatibility of the project's API, we will tag these elements with the  [deprecated = true] option.
 
 It tells other developers that the marked element should no longer be used and the element will be removed in the next major version change.
 
 Where there is alternative functionality available for the functionality deprecated, add some extra comment to explain what would be a better alternative that serves the right behaviour.
 ```
 // At RPC level:
 rpc FooBar(FooBarRequest) returns (FooBarResponse) {
       option deprecated = true;
     };
 
 // At message level
 message Foo {
    option deprecated = true;
    string old_field = 1;
 }
 
 // At Field Level
 message Foo {
     string old_field = 1 [deprecated=true];
 }
 
 Deprecated fields should be marked as reserved
 Fields can be removed, as long as the field number is not used again in your updated message type. Make the field number reserved, so that future users of your .proto can't accidentally reuse the number.
 
 message Foo {
   reserved 2, 15, 9 to 11;
   reserved "foo", "bar";
   string field = 1;
 }
 
 ```
 
 
 ## Semantic Versioning V1.0.0
 Given a version number MAJOR.MINOR.PATCH, increment the:
 
 MAJOR version when you make incompatible API changes,
 
 MINOR version when you add functionality in a backwards compatible manner, and
 
 PATCH version when you make backwards compatible bug fixes.
 
 When changing a MAJOR version, a logging change document must be created with all change details.
 
 
 ## Breaking changes
 We are checking breaking changes between versions of our repository using  Buf.
 
 When adding breaking changes a new version structure should be created in the API following the Buf code style.
 
 All microservices should be able to support multiple versions of a gRPC service.
 
 
 ## API owner
 Responsibility for a service API lies with the team that maintains the associated microservice(s). API definition is driven by the needs of the consumer(s) of the API. 
 