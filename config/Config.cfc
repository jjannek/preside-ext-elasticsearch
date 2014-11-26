component output=false {
	public void function configure( required struct config ) output=false {
		var conf     = arguments.config;
		var settings = conf.settings ?: {};

		settings.adminSideBarItems.append( "elasticsearchControl" );

		settings.filters.elasticSearchPageFilter = {
			filter = "page.internal_search_access is null or page.internal_search_access != 'block'"
		};

		conf.interceptors.prepend(
			{ class="app.extensions.preside-ext-elasticsearch.interceptors.SearchEngineInterceptor", properties={} }
		);

		conf.interceptorSettings.customInterceptionPoints.append( "preElasticSearchCreateIndex"               );
		conf.interceptorSettings.customInterceptionPoints.append( "postElasticSearchCreateIndex"              );
		conf.interceptorSettings.customInterceptionPoints.append( "preElasticSearchRebuildIndex"              );
		conf.interceptorSettings.customInterceptionPoints.append( "postElasticSearchRebuildIndex"             );
		conf.interceptorSettings.customInterceptionPoints.append( "onElasticSearchRebuildIndexFailure"        );
		conf.interceptorSettings.customInterceptionPoints.append( "postElasticSearchGetIndexSettings"         );
		conf.interceptorSettings.customInterceptionPoints.append( "preElasticSearchIndexDoc"                  );
		conf.interceptorSettings.customInterceptionPoints.append( "postElasticSearchIndexDoc"                 );
		conf.interceptorSettings.customInterceptionPoints.append( "preElasticSearchIndexDocs"                 );
		conf.interceptorSettings.customInterceptionPoints.append( "postElasticSearchIndexDocs"                );
		conf.interceptorSettings.customInterceptionPoints.append( "onElasticSearchIndexDocsTermination"       );
		conf.interceptorSettings.customInterceptionPoints.append( "preElasticSearchGetObjectDataForIndexing"  );
		conf.interceptorSettings.customInterceptionPoints.append( "postElasticSearchGetObjectDataForIndexing" );
		conf.interceptorSettings.customInterceptionPoints.append( "preElasticSearchDeleteRecord"              );
		conf.interceptorSettings.customInterceptionPoints.append( "postElasticSearchDeleteRecord"             );
	}
}