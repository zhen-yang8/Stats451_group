//
// This Stan program defines a simple model, with a
// vector of values 'y' modeled as normally distributed
// with mean 'mu' and standard deviation 'sigma'.
//
// Learn more about model development with Stan at:
//
//    http://mc-stan.org/users/interfaces/rstan.html
//    https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started
//
// The input data is a vector 'y' of length 'N'.
data {
  int<lower=0> N;   // # time points (equally spaced)
  vector[N] y;      // mean corrected return at time t
}
parameters {
  real mu_r;                   // mean log return 
  real mu;                     // mean log volatility
  real<lower=-1,upper=1> phi;  // persistence of volatility
  real<lower=0> sigma;         // white noise shock scale
  vector[N] h;                 // log volatility at time t
}
model {
  phi ~ uniform(-1, 1);
  sigma ~ cauchy(0, 5);
  mu ~ cauchy(0, 10);
  h[1] ~ normal(mu, sigma / sqrt(1 - phi * phi));
  for (t in 2:N)
    h[t] ~ normal(mu + phi * (h[t - 1] -  mu), sigma);
  for (t in 1:N)
    y[t] ~ normal(mu_r, exp(h[t] / 2));
}

generated quantities {
  real log_lik[N];
  for (i in 1:N) {log_lik[i] = normal_lpdf(y[i] | mu_r,exp(h[i] / 2));}
}
