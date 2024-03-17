public class swan_AmazonFilesInlinePolicyBuilder {
    
    private String resultPolicy = swan_AmazonFilesConstants.AWS_INLINE_POLICY_TEMPLATE;
    List<String> statements = new List<String>();

    public swan_AmazonFilesInlinePolicyBuilder() {}

    public swan_AmazonFilesInlinePolicyBuilder addStatement(String effect, List<String> actions, String resource) {
       statements.add('{' + String.format(swan_AmazonFilesConstants.AWS_INLINE_POLICY_STATEMENT_TEMPLATE, new List<String>{
            effect,
            String.join(actions, ','),
            resource
        }) + '}' );

        return this;
    }

    public swan_AmazonFilesInlinePolicyBuilder addStatementWithCondition(String effect, List<String> actions, String resource, String condition) {
        statements.add('{' + String.format(swan_AmazonFilesConstants.AWS_INLINE_POLICY_STATEMENT_WITH_CONDITION_TEMPLATE, new List<String>{
             effect,
             String.join(actions, ','),
             resource,
             this.buildCondition(condition)
         }) + '}' );
 
         return this;
     }

    private String buildCondition(String condition) {
        return '{' + '"StringEquals" :' + '{' + condition + '}' + '}';
    }


    public String getResultPolicy() {
        return '{' + String.format(this.resultPolicy, new List<String>{String.join(statements, ',')}) + '}';
    }
}