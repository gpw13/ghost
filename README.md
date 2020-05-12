
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ghost

## Overview

ghost is an R package designed to provide a simple interface for
extracting data from the World Health Organization’s Global Health
Observatory (GHO) database using the [Open Data Protocol
API](https://www.who.int/data/gho/info/gho-odata-api). The package
allows for exploration of indicators and dimensions available in the GHO
and extract of these into R data frames.

  - `gho_indicators()` provides a data frame of all available
    [indicators](https://www.who.int/data/gho/info/gho-odata-api#exe3)
    in the GHO.
  - `gho_dimensions()` provides a data frame of all available
    [dimensions](https://www.who.int/data/gho/info/gho-odata-api#exe1)
    in the GHO.
  - `gho_dimension_values()` provides a data frame of all available
    [values for a single
    dimension](https://www.who.int/data/gho/info/gho-odata-api#exe2) in
    the GHO.
  - `gho_data()` extracts data for any provided indicators in the GHO.

The interface is designed to be as simple as possible, only requiring
input of the code for an indicator to bring it up. However, it is also
compatible with using more complex queries in line with the OData
protocol. Details on its implementation available in the [OData
documentation](https://www.odata.org/documentation/odata-version-2-0/uri-conventions/).

ghost can be installed using
`remotes::install_github("caldwellst\ghost")`

## Usage

To begin, we can use `gho_indicators()` to begin to explore all data
available in the GHO.

``` r
library(ghost)
gho_indicators()
#> # A tibble: 2,268 x 3
#>   IndicatorCode IndicatorName                                           Language
#>   <chr>         <chr>                                                   <chr>   
#> 1 AIR_1         Ambient air pollution attributable deaths               EN      
#> 2 AIR_10        Ambient air pollution  attributable DALYs per 100'000 ~ EN      
#> 3 AIR_11        Household air pollution attributable deaths             EN      
#> 4 AIR_12        Household air pollution attributable deaths in childre~ EN      
#> 5 AIR_13        Household air pollution attributable deaths per 100'00~ EN      
#> # ... with 2,263 more rows
```

If we want the data for `AIR_1`, we could now just quickly access the
data frame using `gho_data()`.

``` r
gho_data("AIR_1")
#> # A tibble: 372 x 20
#>      Id IndicatorCode SpatialDimType SpatialDim TimeDimType TimeDim Dim1Type
#>   <int> <chr>         <chr>          <chr>      <chr>         <int> <lgl>   
#> 1  4882 AIR_1         COUNTRY        AFG        YEAR           2004 NA      
#> 2  4883 AIR_1         COUNTRY        ALB        YEAR           2004 NA      
#> 3  4884 AIR_1         COUNTRY        DZA        YEAR           2004 NA      
#> 4  4885 AIR_1         COUNTRY        AND        YEAR           2004 NA      
#> 5  4886 AIR_1         COUNTRY        AGO        YEAR           2004 NA      
#> # ... with 367 more rows, and 13 more variables: Dim1 <lgl>, Dim2Type <lgl>,
#> #   Dim2 <lgl>, Dim3Type <lgl>, Dim3 <lgl>, DataSourceDimType <lgl>,
#> #   DataSourceDim <lgl>, Value <chr>, NumericValue <dbl>, Low <dbl>,
#> #   High <dbl>, Comments <lgl>, Date <chr>
```

From here, standard methods of data manipulation (e.g. base R, the
tidyverse) could be used to select variables, filter rows, and explore
the data. However, we could also provide OData queries as desired,
filtering on different dimensions of the data. Let’s first have a quick
look at available dimensions.

``` r
gho_dimensions()
#> # A tibble: 86 x 2
#>   Code                  Title                                   
#>   <chr>                 <chr>                                   
#> 1 ADVERTISINGTYPE       SUBSTANCE_ABUSE_ADVERTISING_TYPES       
#> 2 AGEGROUP              Age Group                               
#> 3 ALCOHOLTYPE           Beverage Types                          
#> 4 AMRGLASSCATEGORY      AMR GLASS Category                      
#> 5 AWARENESSACTIVITYTYPE SUBSTANCE_ABUSE_AWARENESS_ACTIVITY_TYPES
#> # ... with 81 more rows
```

Let’s say we want to filter by `COUNTRY`, then we can explore explore
the possible values the SpatialDim `COUNTRY` dimension can take.

``` r
gho_dimension_values("COUNTRY")
#> # A tibble: 216 x 6
#>   Code  Title        Dimension ParentDimension ParentCode ParentTitle
#>   <chr> <chr>        <chr>     <chr>           <chr>      <chr>      
#> 1 AGO   Angola       COUNTRY   REGION          AFR        Africa     
#> 2 BDI   Burundi      COUNTRY   REGION          AFR        Africa     
#> 3 BEN   Benin        COUNTRY   REGION          AFR        Africa     
#> 4 BFA   Burkina Faso COUNTRY   REGION          AFR        Africa     
#> 5 BWA   Botswana     COUNTRY   REGION          AFR        Africa     
#> # ... with 211 more rows
```

If we wanted to only extract `AIR_1` data on Burundi from the GHO, then
we can now implement an OData query using the code we’ve identified
above.

``` r
gho_data("AIR_1", "$filter=SpatialDim eq 'BDI'")
#> # A tibble: 2 x 20
#>      Id IndicatorCode SpatialDimType SpatialDim TimeDimType TimeDim Dim1Type
#>   <int> <chr>         <chr>          <chr>      <chr>         <int> <lgl>   
#> 1  4909 AIR_1         COUNTRY        BDI        YEAR           2004 NA      
#> 2 21904 AIR_1         COUNTRY        BDI        YEAR           2008 NA      
#> # ... with 13 more variables: Dim1 <lgl>, Dim2Type <lgl>, Dim2 <lgl>,
#> #   Dim3Type <lgl>, Dim3 <lgl>, DataSourceDimType <lgl>, DataSourceDim <lgl>,
#> #   Value <chr>, NumericValue <dbl>, Low <lgl>, High <lgl>, Comments <lgl>,
#> #   Date <chr>
```

And we can collect information on multiple indicators in one call, with
the data frames already merged together.

``` r
gho_data(c("AIR_1", "AIR_10", "AIR_11"), "$filter=SpatialDim eq 'BDI'")
#> # A tibble: 21 x 20
#>       Id IndicatorCode SpatialDimType SpatialDim TimeDimType TimeDim Dim1Type
#>    <int> <chr>         <chr>          <chr>      <chr>         <int> <chr>   
#> 1 4.91e3 AIR_1         COUNTRY        BDI        YEAR           2004 <NA>    
#> 2 2.19e4 AIR_1         COUNTRY        BDI        YEAR           2008 <NA>    
#> 3 6.48e3 AIR_10        COUNTRY        BDI        YEAR           2004 <NA>    
#> 4 1.96e7 AIR_11        COUNTRY        BDI        YEAR           2016 SEX     
#> 5 1.96e7 AIR_11        COUNTRY        BDI        YEAR           2016 SEX     
#> # ... with 16 more rows, and 13 more variables: Dim1 <chr>, Dim2Type <chr>,
#> #   Dim2 <chr>, Dim3Type <lgl>, Dim3 <lgl>, DataSourceDimType <lgl>,
#> #   DataSourceDim <lgl>, Value <chr>, NumericValue <dbl>, Low <dbl>,
#> #   High <dbl>, Comments <lgl>, Date <chr>
```

We can even provide different filters for each variable separately, such
as Burundi for `AIR_1`, Uganda for `AIR_10`, and South Africa for
`AIR_11`.

``` r
gho_data(c("AIR_1", "AIR_10", "AIR_11"), 
         c("$filter=SpatialDim eq 'BDI'", "$filter=SpatialDim eq 'UGA'", "$filter=SpatialDim eq 'ZAF'"))
#> # A tibble: 21 x 20
#>       Id IndicatorCode SpatialDimType SpatialDim TimeDimType TimeDim Dim1Type
#>    <int> <chr>         <chr>          <chr>      <chr>         <int> <chr>   
#> 1 4.91e3 AIR_1         COUNTRY        BDI        YEAR           2004 <NA>    
#> 2 2.19e4 AIR_1         COUNTRY        BDI        YEAR           2008 <NA>    
#> 3 6.61e3 AIR_10        COUNTRY        UGA        YEAR           2004 <NA>    
#> 4 1.96e7 AIR_11        COUNTRY        ZAF        YEAR           2016 SEX     
#> 5 1.96e7 AIR_11        COUNTRY        ZAF        YEAR           2016 SEX     
#> # ... with 16 more rows, and 13 more variables: Dim1 <chr>, Dim2Type <chr>,
#> #   Dim2 <chr>, Dim3Type <lgl>, Dim3 <lgl>, DataSourceDimType <lgl>,
#> #   DataSourceDim <lgl>, Value <chr>, NumericValue <dbl>, Low <dbl>,
#> #   High <dbl>, Comments <lgl>, Date <chr>
```

Of course, the reality is that it’s likely easier for us to work outside
the OData filtering framework and directly in R, so here’s a final more
complex example using dplyr and stringr alongside ghost to automatically
download all indicators with the word “drug” in the indicator name (case
insensitive).

``` r
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
library(stringr)

gho_indicators() %>%
  filter(str_detect(str_to_lower(IndicatorName), "drug")) %>%
  pull(IndicatorCode) %>%
  gho_data()
#> # A tibble: 25,302 x 20
#>       Id IndicatorCode SpatialDimType SpatialDim TimeDimType TimeDim Dim1Type
#>    <int> <chr>         <chr>          <chr>      <chr>         <int> <chr>   
#> 1 273692 MALARIA_30539 COUNTRY        MWI        YEAR           2004 RESIDEN~
#> 2 273693 MALARIA_30539 COUNTRY        MWI        YEAR           2004 RESIDEN~
#> 3 273694 MALARIA_30539 COUNTRY        MWI        YEAR           2004 <NA>    
#> 4 273695 MALARIA_30539 COUNTRY        TZA        YEAR           2004 RESIDEN~
#> 5 273714 MALARIA_30539 COUNTRY        BDI        YEAR           2005 RESIDEN~
#> # ... with 25,297 more rows, and 13 more variables: Dim1 <chr>, Dim2Type <lgl>,
#> #   Dim2 <lgl>, Dim3Type <lgl>, Dim3 <lgl>, DataSourceDimType <chr>,
#> #   DataSourceDim <lgl>, Value <chr>, NumericValue <dbl>, Low <lgl>,
#> #   High <lgl>, Comments <lgl>, Date <chr>
```
