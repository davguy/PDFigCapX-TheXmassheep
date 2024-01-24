# Poor Man's Majorana Stochastic Gradient Descent


The following algorithm has been designed to solve the poroblem of tuning two quantum dots to a PMM sweet spot. 
It has been designed with the following objectives : to minimimze $| \Delta - t |$ for non-zero $\Delta$ and $t$ , to stay away from low interacting regimes, and to do so in a stable manner without excessive changes in gate voltages. 



The gradient descent algorithm which tunes the ABS voltage is implemented as follows : 

- Initialize the learning rate $\eta$ , the momentum term $\beta$, the gate value $V_0$, the velocity $v_0$, and the tolerance $\varepsilon$
- A direction is randomly chosen for the first step, which is 20 times the minimum step, to give $V_1$ 
- The following steps are repeated until the objective function is within tolerance : 
- A gate 2d plunger gate sweep of the left and right dots is performed, and the resulting charge stability diagram is saved
- The classifier result estimating $(\Delta - t) / (\Delta + t) $ is computed : $P_i = CNN( CSD(V_i)) $
- If $sign(P_i) = - sign(P_{i-1})$ , the CNN has predicted a switch between the ECT and CAR regimes. Therefore, we reverse the current velocity $v_i \to -v_i$ and decrease the learning rate by a predefined damping coefficient to take smaller steps 
- The objective function is computed : $$f_i = abs(P_i) + (pixel count)^{-3}$$ In this function the pixels counted are those pixels with a conductance value higher than the mean conductance of the most conductive half of CSD pixels. For very low interaction, this results in few pixels being counted and the pixels term is of the same order as $P_i$. Around suitable sweet spots this term is several orders of magnitude smaller. 
- If $f_i < \varepsilon$ , the algorithm has converged and $V_i$ is returned as a plunger gate value at a suitable sweet spot. Otherwise : 
- The last N points are used to compute the most recent N - 1 gradients. The median of these gradients is denoted $gr_i$. 
- The next velocity is updated as follows : $$ v_{i+1} = \beta v_i + (1-\beta) gr_i $$ 
- The next gate value is given by $$V_{i+1} = V_i - \eta v_{i+1}$$ , if this jump is not greater than the maximum step size. If it is, take the maximum step size fixed by the user. 
- Continue this algorithm until convergence or until the maximum number of epochs has been reached. 






Remarks on the algorithm : 
- The median is used because the classification can be noisy and lead to either very sharp or very flat gradients. To moderate the strong variance in the measured gradients, the median is used. Using the average often lead to too large jumps. 
- The optimal number of recent points to use was found to be N = 5. Less points leads to a very sharp exploration of the gate space, while more points leads to a strong overshoot of the minimum. 
- A momentum value of 0.5 is typically used because, when overshooting this leads to a very small next step since $v_i$ and $gr_i$ then contribute similarly but are often of a different sign. This is desirable if we are close to a minimum, as overshoots tend to suggest. However any value $\beta \in [0,1] $ may be used.  
- A damping factor of 2 seemed to be the most effective
- All details of the predictions and convergence are saved in a logging file which can be specified when calling the function. 
- The plot below shows the classifier results with the pixel term (red) and without (black). The region where only black dots go to zero is a false positive, as both $\Delta$ and $t$ vanish.  
<img src="regularized_vs_normal.png" alt="drawing" width="400"/>
- The CNN has been trained on well-defined dots. Strong ABS hybridization will lead to a noisy objective function and will strongly impact convergence. 
- 