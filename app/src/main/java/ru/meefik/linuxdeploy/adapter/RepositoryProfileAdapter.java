package ru.meefik.linuxdeploy.adapter;


import android.annotation.SuppressLint;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.recyclerview.widget.RecyclerView;

import java.util.List;

import ru.meefik.linuxdeploy.R;
import ru.meefik.linuxdeploy.model.RepositoryProfile;

public class RepositoryProfileAdapter extends RecyclerView.Adapter<
        RepositoryProfileAdapter.RepositoryProfileViewHolder> {

    private List<RepositoryProfile> RepositoryProfileList;
    private Context context;

    private OnItemClickListener listener;

    public  RepositoryProfileAdapter
            (List<RepositoryProfile> _RepositoryProfileList, Context _context){
        RepositoryProfileList = _RepositoryProfileList;
        context = _context;
    }

    @Override
    public RepositoryProfileAdapter.RepositoryProfileViewHolder onCreateViewHolder(
            ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(
                R.layout.repository_row,parent,false);
        return new RepositoryProfileViewHolder(view);
    }

    @Override
    public void onBindViewHolder(RepositoryProfileViewHolder holder,
                                 @SuppressLint("RecyclerView") int position){

        RepositoryProfile repositoryprofile = RepositoryProfileList.get(position);
        holder.RepositoryProfile_icon.setImageResource(repositoryprofile.getIconId());
        holder.RepositoryProfile_type.setText(repositoryprofile.getType());
        holder.RepositoryProfile_description.setText(repositoryprofile.getDescription());

    }


    public class RepositoryProfileViewHolder extends RecyclerView.ViewHolder{
        ImageView RepositoryProfile_icon;
        TextView RepositoryProfile_type;
        TextView RepositoryProfile_description;

        public RepositoryProfileViewHolder (View view)
        {
            super(view);
            RepositoryProfile_icon = (ImageView) view.findViewById(R.id.repo_entry_icon);
            RepositoryProfile_type = (TextView) view.findViewById(R.id.repo_entry_title);
            RepositoryProfile_description = (TextView) view.findViewById(R.id.repo_entry_subtitle);

            view.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    if (listener != null){
                        listener.onClick(RepositoryProfileList.get(
                                getAdapterPosition()));
                    }
                }
            });
        }

    }

    @Override
    public int getItemCount(){
        return RepositoryProfileList.size();
    }

    public void setOnItemClickListener(OnItemClickListener listener) {
        this.listener = listener;
    }

    public interface OnItemClickListener {
        void onClick(RepositoryProfile repositoryProfile);
    }


}
