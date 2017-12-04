component extends="coldbox.system.Interceptor" {

	property name="elasticSearchEngine"        inject="provider:elasticSearchEngine";
	property name="systemConfigurationService" inject="delayedInjector:systemConfigurationService";
	property name="presideObjectService"       inject="delayedInjector:presideObjectService";
	property name="adhocTaskmanagerService"    inject="delayedInjector:adhocTaskmanagerService";

// PUBLIC
	public void function configure() {}

	public void function preElasticSearchIndexDoc( event, interceptData ) {
		_getSearchEngine().processPageTypeRecordsBeforeIndexing(
			  objectName = interceptData.objectName ?: ""
			, records    = interceptData.doc        ?: []
		);
	}
	public void function preElasticSearchIndexDocs( event, interceptData ) {
		_getSearchEngine().processPageTypeRecordsBeforeIndexing(
			  objectName = interceptData.objectName ?: ""
			, records    = interceptData.docs       ?: []
		);
	}

	public void function postInsertObjectData( event, interceptData ) {
		var objectName = interceptData.objectName ?: "";

		var isPageType = presideObjectService.getObjectAttribute( objectName, "isPageType" , false );

		if ( ( IsBoolean( interceptData.skipTrivialInterceptors ?: "" ) && interceptData.skipTrivialInterceptors ) || isPageType ||  objectName == 'page' ) {
			return;
		}
		var id = Len( Trim( interceptData.newId ?: "" ) ) ? interceptData.newId : ( interceptData.data.id ?: "" );

		if ( Len( Trim( id ) ) ) {
			adhocTaskmanagerService.createTask(
				  event  = "admin.elasticSearchControl.indexRecord"
				, args   = {
					  objectName = objectName
					, id         = id
				}
				, runNow = true
			);
		}
	}

	public void function postAddSiteTreePage( event, interceptData ) {
		var id = interceptData.id ?: "";

		if ( Len( Trim( id ) ) ) {
			adhocTaskmanagerService.createTask(
				  event  = "admin.elasticSearchControl.indexRecord"
				, args   = { objectName=interceptData.page_type ?: "", id=id }
				, runNow = true
			);
		}
	}

	public void function postUpdateObjectData( event, interceptData ) {
		if ( IsBoolean( interceptData.skipTrivialInterceptors ?: "" ) && interceptData.skipTrivialInterceptors ) {
			return;
		}

		var objectName = interceptData.objectName ?: "";
		var id = Len( Trim( interceptData.id ?: "" ) ) ? interceptData.id : ( interceptData.data.id ?: "" );

		if ( Len( Trim( objectName ) ) && Len( Trim( id ) ) ) {
			var reindexChildPages = systemConfigurationService.getSetting( "elasticsearch", "reindex_child_pages_on_edit", true )
			adhocTaskmanagerService.createTask(
				  event  = "admin.elasticSearchControl.indexRecord"
				, args   = {
					  objectName        = objectName
					, id                = id
					, reindexChildPages = reindexChildPages
					, data              = interceptData.data ?: {}
				}
				, runNow = true
			);
		}
	}

	public void function preDeleteObjectData( event, interceptData ) {
		if ( IsBoolean( interceptData.skipTrivialInterceptors ?: "" ) && interceptData.skipTrivialInterceptors ) {
			return;
		}

		var objectName = interceptData.objectName ?: "";
		var id         = interceptData.id ?: "";
		if ( !Len( Trim( id ) ) ) {
			id = interceptData.filter.id ?: ( interceptData.filterParams.id ?: "" );
		}
		if ( IsArray( id ) ) {
			id = id.toList();
		}

		if ( IsSimpleValue( id ) && Len( Trim( id ) ) ) {
			adhocTaskmanagerService.createTask(
				  event  = "admin.elasticSearchControl.deleteRecord"
				, args   = {
					  objectName = objectName
					, id         = id
				}
				, runNow = true
			);
		}
	}

// PRIVATE
	private any function _getSearchEngine() {
		return elasticSearchEngine.get();
	}
}