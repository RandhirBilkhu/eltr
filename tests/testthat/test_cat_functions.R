context("function testing")

library(catr)
set.seed(1)

elt <- create_elt(example_elt, ann_rate="rate", mu="mean", sdev_i = "sdevi" , sdev_c = "sdevc", expval = "exp")
ylt <- create_ylt(elt, sims=10 ,ann_rate = "rate" , event_id = "id", expval = "exp" , mu ="mean")
ann <-ylt[ ,Loss :=sum(Loss) , by=Year]

ep <- create_ep_curve(ann , y= "Year", z="Loss")

testthat::test_that("layer loss is correct", {
  expect_equal(layer_loss(10,2,5),5)

})


testthat::test_that("elt normalised rate correct",{
  expect_equal(   sum(elt$random_num) ,1)

})


testthat::test_that("ylt creation",{
  expect_equal(   sum(ylt$Loss),  13833.1, tolerance=0.01)

})


testthat::test_that("OEP",{
  expect_equal(   sum(ep$OEP),  167425.6 , tolerance=0.01)

})


