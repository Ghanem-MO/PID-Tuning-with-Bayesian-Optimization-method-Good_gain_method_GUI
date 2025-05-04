What is Bayesian Optimization (BO)?
Bayesian Optimization is a statistical method used to optimize black-box functions that are expensive to evaluate. In the context of PID controller tuning, BO helps to efficiently find optimal values for the controller's proportional, integral, and derivative gains by iterating through potential settings and learning from each iteration's feedback. This method is particularly advantageous in scenarios where real-time feedback from controllers is necessary and where traditional tuning methods may be time-consuming or risky.

Good gain tuning (Another method) :
"Good Gain" tuning is a practical method for tuning PID controllers, especially suitable for industrial applications. It focuses primarily on tuning the proportional gain (Kp) to achieve a desired response with minimal overshoot and then refining the response with integral (Ki) and
