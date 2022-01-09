package ru.meefik.linuxdeploy.activity;


import android.content.Intent;
import android.graphics.Rect;
import android.net.Uri;
import android.os.Bundle;
import android.view.View;

import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.DividerItemDecoration;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import java.util.ArrayList;
import java.util.List;

import ru.meefik.linuxdeploy.PrefStore;
import ru.meefik.linuxdeploy.R;
import ru.meefik.linuxdeploy.adapter.RepositoryProfileAdapter;
import ru.meefik.linuxdeploy.model.RepositoryProfile;

public class RepositoryActivity extends AppCompatActivity {

    private RepositoryProfileAdapter adapter;
    private List<RepositoryProfile> RepositoryProfileList = new ArrayList<>();


    private void importDialog(RepositoryProfile repositoryProfile) {
        String type = repositoryProfile.getType();
        String message = getString(R.string._repository_import_message,
                repositoryProfile.getExtractionCode());
        String url = repositoryProfile.geturl();

        AlertDialog.Builder dialog = new AlertDialog.Builder(this)
                .setTitle(type)
                .setMessage(message)
                .setCancelable(false);
        dialog.setPositiveButton(R.string.repository_goto_button,
                (dialog1,whichButton)->startActivity(new Intent(Intent.ACTION_VIEW,
                        Uri.parse(url))));
        dialog.setNegativeButton(android.R.string.no,
                (dialog2,whichButton)-> dialog2.cancel());
        dialog.show();

    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        PrefStore.setLocale(this);
        setContentView(R.layout.activity_repository);

        initRepositoryProfile();

        RecyclerView recyclerView = (RecyclerView) findViewById(R.id.repositoryView);

        LinearLayoutManager layoutManager = new LinearLayoutManager(this);
        recyclerView.setLayoutManager(layoutManager);

        recyclerView.addItemDecoration(
                new DividerItemDecoration(this,
                        DividerItemDecoration.VERTICAL));

        RepositoryProfileAdapter adapter =
                new RepositoryProfileAdapter(RepositoryProfileList,this);
        recyclerView.setAdapter(adapter);

        adapter.setOnItemClickListener(this::importDialog);

    }

    @Override
    public void setTheme(int resId) {
        super.setTheme(PrefStore.getTheme(this));
    }

    private void initRepositoryProfile() {
        RepositoryProfile ubuntu = new RepositoryProfile("Ubuntu",R.raw.ubuntu);
        ubuntu.setDescription("Contian Ubuntu21.04 Ubuntu21.10 Ubuntu22.01");
        ubuntu.seturl("https://pan.baidu.com/s/1Bj5zuqPtYaaee9D5TA7ebg");
        ubuntu.setExtractionCode("38od");
        RepositoryProfileList.add(ubuntu);

        RepositoryProfile debian = new RepositoryProfile("Debian",R.raw.debian);
        debian.setDescription("Contian Debian11 Debian12");
        debian.seturl("https://pan.baidu.com/s/14GMi-5-mZMik08qSOvG5Gg");
        debian.setExtractionCode("6627");
        RepositoryProfileList.add(debian);

        RepositoryProfile kali = new RepositoryProfile("Kali",R.raw.kali);
        kali.setDescription("Contian kali-rolling");
        kali.seturl("https://pan.baidu.com/s/1ggjfMFxnf0D_AyeGCtYlLw");
        kali.setExtractionCode("ypch");
        RepositoryProfileList.add(kali);
    }

}
