

for sub = 2:1:num_subj
    if sub == 5
        min_val = 999999;
        for wm = 0.2:0.01:0.5 %start from bigger than 0.2 and up to larger bound
            for wp = 0.001:0.01:0.3%try diff
                error_sq = 0;
                
                for distr = 1:num_distr
                    for trial = 2:1:num_trials
                        eval(['Z = Sub',num2str(sub),'_',num2str(distr),'(',num2str(trial),',3);']);
                        
                        %updating each particle
                        for particle = 1:num_particles
                            X_P_update(sub,distr,particle) = abs(X_P(sub,distr,particle) + wm*X_P(sub,distr,particle)*randn+eps);
                            Z_update(particle,1) = X_P_update(sub,distr,particle);
                            Weight(particle,1) = normpdf(Z,Z_update(particle,1),wp*Z_update(particle,1));
                        end
                        
                        for zzz = 1:num_particles
                            if Weight(zzz,1) < eps
                                Weight(zzz,1) = 0.0001;
                            end
                        end
                        
                        
                        %normalizing the weight
                        if sum(Weight)<eps
                            for ww = 1:num_particles
                                Weight(ww,1) = 1/num_particles;
                            end
                            
                        else
                            sumt = sum(Weight);
                            Weight = Weight./sumt;
                        end
                        
                        %resampling
                        for particle = 1 : num_particles
                            X_P(sub,distr,particle) = X_P_update(sub,distr,find(rand<=cumsum(Weight),1));
                        end
                        
                        %estimate: using the particle of highest weight
                        Tp = mean(X_P(sub,distr,:));
                        result_vector(sub,distr,trial) = Tp;
                        eval(['error_sq = error_sq + (Tp - Sub',num2str(sub),'_', num2str(distr),'(',num2str(trial),',3))^2;' ]);
                    end
                end
                wm
                wp
                %% get params here
                if error_sq<min_val
                    min_val = error_sq
                    least_sum(sub,1) = error_sq;
                    best_param_refined(sub,1) = wm
                    best_param_refined(sub,2) = wp
                end
            end
        end
    end
end



