addpath('../util/jsonlab')

dirs = {'original/testingdata/cpp/oqp', 'original/testingdata/cpp/problems'};

for i = 1:numel(dirs)
    dir_list = readdir(dirs{i});
    qp_list = dir_list(!(strcmp(dir_list, '..') | strcmp(dir_list, '.')));

    for j = 1:numel(qp_list)
        path = [dirs{i}, '/', qp_list{j}]
        output_path = ['json/'];


        dims = load([path, '/dims.oqp']);
        number_qp = dims(1);
        number_general_ctr  = dims(3);

        H  = load([path, '/H.oqp']);
        g  = load([path, '/g.oqp']);

        % bounds
        lb = load([path, '/lb.oqp']);
        ub = load([path, '/ub.oqp']);

        % general constraints
        if ( number_general_ctr > 0 )
            Ain  = load([path, '/A.oqp']);
            lbin = load([path, '/lbA.oqp']);
            ubin = load([path, '/ubA.oqp']);
        end

        % flags
        positive_definite = min(eig(H)) > 1e-13;
        has_obj = exist([path, '/obj_opt.oqp'], 'file');

        % solutions
        x_ref = load([path, '/x_opt.oqp']);
        if (has_obj)
            obj_ref = load([path, '/obj_opt.oqp']);
        end



        if (1 == number_qp)
            qp.objective.positive_definite = positive_definite;
            qp.objective.hessian = H;
            qp.objective.vector = g(:);

            % bounds
            qp.bounds.lower = lb(:);
            qp.bounds.upper = ub(:);

            % general constraints
            if ( number_general_ctr > 0 )
                qp.constraints.matrix  = Ain;
                qp.constraints.lower = lbin(:);
                qp.constraints.upper = ubin(:);
            end

            % solutions
            qp.solution.vector = x_ref(:);
            if (has_obj)
                qp.solution.value = obj_ref;
            end

            qp = orderfields(qp);
            savejson('qp', qp, 'FileName', [output_path, '/oneshot/', qp_list{j}, '.json'], 'FloatFormat', '%.20g', 'ArrayIndent', 0, 'SingletArray', 1);
        else
            qp_iterative.common.objective.positive_definite = positive_definite;
            qp_iterative.common.objective.hessian = H;

            % general constraints
            if ( number_general_ctr > 0 )
                qp_iterative.common.constraints.matrix = Ain;
            end

            qp_iterative.instances = {};
            for k = 1:number_qp
                qp.objective.vector = g(k,:)(:);

                qp.bounds.lower = lb(k, :)(:);
                qp.bounds.upper = ub(k, :)(:);

                if ( number_general_ctr > 0 )
                    qp.constraints.lower = lbin(k,:)(:);
                    qp.constraints.upper = ubin(k,:)(:);
                end

                qp.solution.vector = x_ref(k,:)(:);
                if (has_obj)
                    qp.solution.value = obj_ref(k);
                end

                qp_iterative.instances(end + 1) = qp;
            end

            qp_iterative = orderfields(qp_iterative);
            savejson('qp_iterative', qp_iterative, 'FileName', [output_path, '/iterative/', qp_list{j}, '.json'], 'FloatFormat', '%.20g', 'ArrayIndent', 0, 'SingletArray', 1);
        end
    end
end
