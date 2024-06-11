(module dotfiles.plugins.neuron
  {autoload {neuron neuron}})

(neuron.setup {:virtual_titles true
               ; :mappings true,
               ; :run nil ; function to run when in neuron dir
               :neuron_dir "~/notes"
               :leader "gz"}) ; the leader key to for all mappings, remember with 'go zettel'})
